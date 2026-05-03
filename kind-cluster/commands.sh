function install_kind {
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
}

function create_cluster {
    kind create cluster --config kind-cluster.yaml
    kubectl create secret tls example-tls-secret --cert certificate.pem --key key.pem
}

# Ingress controller installeren
function install_ingress {
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s
}

function install_loadbalancer {
    wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz

    echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc

    go install sigs.k8s.io/cloud-provider-kind@latest
    sudo install ~/go/bin/cloud-provider-kind /usr/local/bin
    sudo cloud-provider-kind
}
