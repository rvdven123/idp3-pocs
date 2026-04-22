
openssl req -subj '/CN=test.keycloak.org/O=Test Keycloak./C=US' -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem

#Operator installatie status controleren
kubectl get csv -n default

kubectl create secret generic keycloak-db-secret \
  -n default \
  --from-literal=testuser=testuser \
  --from-literal=testpassword=testpassword

kubectl apply -f postgres.yaml

kubectl delete -f keycloak.yaml
kubectl apply -f keycloak.yaml

function watch_events() {
  echo "watching events in the default namespace..."
  kubectl get events -n default   --sort-by=.metadata.creationTimestamp   --watch
}

kubectl describe pod example-kc-0

kubectl logs example-kc-0

kubectl apply -f keycloak-ingress.yaml