#moet gebeuren voor operator install.
kubectl apply -f nginx-ingress.yaml

kubectl create namespace gitlab-system

kubectl operator install gitlab-operator-kubernetes -C -n gitlab-system --channel stable --approval Automatic

#Controller manager status controleren
kubectl -n gitlab-system get deployment gitlab-controller-manager

#Cert-manager installeren
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl apply -f gitlab.yaml -n gitlab-system

#Status controleren
kubectl -n gitlab-system logs deployment/gitlab-controller-manager -c manager -f



