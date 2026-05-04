sudo apt install -y make git curl

git clone https://github.com/submariner-io/submariner-operator
cd submariner-operator
make clusters

curl -Ls https://get.submariner.io | bash
export PATH=$PATH:~/.local/bin
echo export PATH=\$PATH:~/.local/bin >> ~/.profile

subctl deploy-broker \
  --context kind-a 

function undeploy_broker() {
 subctl uninstall --context kind-a
 subctl uninstall --context kind-b
}

subctl join --context kind-a broker-info.subm --clusterid kind-a --natt=false 

subctl join --context kind-b broker-info.subm --clusterid kind-b --natt=false

subctl verify --context kind-a --tocontext kind-b --only service-discovery,connectivity --verbose
