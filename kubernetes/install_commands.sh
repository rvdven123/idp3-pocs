#Tools nodig op de host machine:

function install_stern {
    go install github.com/stern/stern@1.33.1
    echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.bashrc
    source ~/.bashrc
    stern --version
}

sudo apt install -y yq

