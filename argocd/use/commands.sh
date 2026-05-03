#see https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/

argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default

function example_application() {
    kubectl create ns guestbook
    kubectl apply -f ~/source/idp3-pocs/argocd/use/application.yaml
}

kubectl get applications -n argocd

stern "argocd-application-controller.*" | grep failed

kubectl get pods -n guestbook