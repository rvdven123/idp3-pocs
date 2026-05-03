kubectl create -f https://github.com/operator-framework/operator-lifecycle-manager/releases/latest/download/crds.yaml
kubectl create -f https://github.com/operator-framework/operator-lifecycle-manager/releases/latest/download/olm.yaml

#Listen van de beschikbare operators in de cluster
kubectl get packagemanifest -n olm | more

#Install brew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl krew install operator

kubectl operator install cert-manager -n operators --channel stable --approval Automatic


