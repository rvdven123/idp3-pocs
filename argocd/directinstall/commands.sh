kubectl create namespace argocd

kubectl apply -n argocd   --server-side   --force-conflicts   -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.3.8/manifests/install.yaml

kubectl get pods -n argocd --watch

kubectl apply -f argocd_ingress_443.yaml

kubectl get ingress -n argocd 

open https://argocd.127-0-0-1.nip.io/

kubectl get svc -n argocd

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

66wHYrbHaX8L945-
