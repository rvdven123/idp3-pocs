function watch_events() {
    echo "Watching GitLab events in the gitlab-system namespace..." 
    kubectl get events -n $1 --sort-by=.metadata.creationTimestamp --watch
}

function set_namespace() {
    echo "Setting current namespace to $1..."
    kubectl config set-context --current --namespace=$1
}

function set_default_namespace() {
    echo "Setting default namespace to $1..."
    kubectl config set-context --current --namespace=$1
}