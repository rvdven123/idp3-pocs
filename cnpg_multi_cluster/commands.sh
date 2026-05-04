#build everthing with a docker container inside the same docker network 
#as the kind control plane containers to prevent the issue with submariner that the control-plane of cluster a cannot access the control-plane
# of cluster b via localhost
docker build --pull --rm  -t 'submarine-toolbox:latest' . 

docker run -it --rm \
  --network kind-shared \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube \
  -v "$PWD":/work \
  -w /work \
  submarine-toolbox:latest 

docker network create kind-shared

kind delete cluster -n a
kind create cluster --name a --config kind-a.yaml
docker network connect kind-shared a-control-plane

kind delete cluster -n b
kind create cluster --name b --config kind-b.yaml
docker network connect kind-shared b-control-plane

docker network inspect kind-shared

#patch the kubeconfig to use the control-plane hostnames instead of localhost, 
# as kind by default uses localhost with random ports to access the api-server, but submariner needs to access the api-server of the other cluster via the control-plane hostnames
kubectl config set-cluster kind-a --server=https://a-control-plane:6443
kubectl config set-cluster kind-b --server=https://b-control-plane:6443

#install the operator in cluster a
kubectl --context kind-a   --server-side --force-conflicts  apply -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml

#create database in a  
kubectl --context kind-a create ns database
kubectl --context kind-a apply -f cnpg-a.yaml -n database
kubectl --context kind-a get deploy -n cnpg-system cnpg-controller-manager
kubectl --context kind-a describe deployment/cnpg-controller-manager -n cnpg-system 
kubectl --context kind-a get pods -n database -w

#expose nodeport of cluster a to b, but not when using submariner, as submariner will handle the connectivity between the clusters, and we can use the internal cluster hostnames to access the api-server of the other cluster
kubectl --context kind-a delete -f kind_a_expose_nodeport.yaml
kubectl --context kind-a apply -f kind_a_expose_nodeport.yaml
docker exec b-control-plane curl telnet://a-control-plane:30432
kubectl --context kind-a get svc -n database

#creat database namespaces  
kubectl --context kind-b create ns database

#copy secrets from cluster a to cluster b
kubectl --context kind-a -n database get secret pg-a-replication -o yaml \
| yq 'del(
    .metadata.uid,
    .metadata.resourceVersion,
    .metadata.creationTimestamp,
    .metadata.ownerReferences,
    .metadata.managedFields
  )' \
 | kubectl --context kind-b apply -f -
kubectl --context kind-b -n database get secret pg-a-replication

kubectl --context kind-a -n database get secret pg-a-ca -o yaml \
| yq 'del(
    .metadata.uid,
    .metadata.resourceVersion,
    .metadata.creationTimestamp,
    .metadata.ownerReferences,
    .metadata.managedFields
  )' \
| kubectl --context kind-b -n database apply -f -
kubectl --context kind-b -n database get secret pg-a-ca

#delete operator  
kubectl --context kind-b delete -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml
#create operator in kind-b
kubectl --context kind-b --server-side --force-conflicts  apply -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml
kubectl --context kind-b get deploy -n cnpg-system cnpg-controller-manager -w

# run submariner to connect the clusters and test the replication between the clusters,
#see commands_submariner.sh for the commands
./commands_submariner.sh

#create postgres cluster b
kubectl --context kind-b delete -f cnpg-b.yaml -n database
kubectl --context kind-b apply -f cnpg-b.yaml -n database
kubectl --context kind-b get pods -n database -w

function test_replicatie(){
#!/bin/bash

set -e

NS=database
DB=postgres

echo "🔹 Stap 1: Testdata schrijven naar cluster A"
kubectl --context kind-a -n $NS exec -i pg-a-1 -- \
psql -U postgres -d $DB <<'EOF'
CREATE TABLE IF NOT EXISTS repl_test (
id serial primary key,
msg text,
created_at timestamptz default now()
);

INSERT INTO repl_test (msg) VALUES ('test vanaf cluster-a');

SELECT * FROM repl_test ORDER BY id DESC LIMIT 3;
EOF

echo ""
echo "🔹 Stap 2: Data lezen op cluster B (replica)"
kubectl --context kind-b -n $NS exec -i pg-b-1 -- \
psql -U postgres -d $DB -c "SELECT * FROM repl_test ORDER BY id DESC LIMIT 3;"

echo ""
echo "🔹 Stap 3: Check recovery mode"

echo "Cluster A (primary):"
kubectl --context kind-a -n $NS exec -i pg-a-1 -- \
psql -U postgres -d $DB -c "SELECT pg_is_in_recovery();"

echo "Cluster B (replica):"
kubectl --context kind-b -n $NS exec -i pg-b-1 -- \
psql -U postgres -d $DB -c "SELECT pg_is_in_recovery();"

echo ""
echo "🔹 Stap 4: Replication status (cluster A)"

kubectl --context kind-a -n $NS exec -i pg-a-1 -- \
psql -U postgres -d $DB -c "
SELECT application_name, state, sync_state,
    sent_lsn, write_lsn, flush_lsn, replay_lsn
FROM pg_stat_replication;
"

echo ""
echo "🔹 Stap 5: Replication lag (cluster B)"

kubectl --context kind-b -n $NS exec -i pg-b-1 -- \
psql -U postgres -d $DB -c "
SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;
"

echo ""
echo "✅ Test klaar"

}