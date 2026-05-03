kubectl create namespace argocd

kubectl create -n olm -f argo_catalog_source.yaml

kubectl get catalogsources -n olm

#verify catalog source pod is running
kubectl get pods -n olm -l olm.catalogSource=argocd-catalog

#create operator group that watches argo cd namespace.
kubectl create -n argocd2 -f argo_operator_group.yaml

#verify operator group is created
kubectl get operatorgroups -n argocd

#create subscription to argocd operator
kubectl create -n argocd2 -f argo_catalog_subscription.yaml

#verify subscription is created and install plan is pending
kubectl get subscriptions -n argocd2

kubectl get installplans -n argocd2

kubectl get pods -n argocd2


kubectl delete -n argocd -f argo_catalog_subscription.yaml
kubectl delete -n argocd -f argo_operator_group.yaml
kubectl delete -n olm -f argo_catalog_source.yaml
kubectl delete namespace argocd


kubectl create namespace argocd-operator-system


kubectl apply -k "https://github.com/argoproj-labs/argocd-operator/config/default?ref=v0.17.0"


NS=argocd-operator-system
kubectl get namespace $NS -o json > ns.json

kubectl replace --raw "/api/v1/namespaces/$NS/finalize" -f ./ns.json

kubectl api-resources --verbs=list --namespaced -o name \
| xargs -n 1 kubectl get -n argocd-operator-system --ignore-not-found -o name 


kubectl delete subscriptions --all -n $NS
kubectl delete installplans --all -n $NS
kubectl delete csv --all -n $NS
kubectl delete operatorgroups --all -n $NS

kubectl apply -n argocd -f   --server-side \
  --force-conflicts https://raw.githubusercontent.com/argoproj/argo-cd/v3.3.8/manifests/install.yaml