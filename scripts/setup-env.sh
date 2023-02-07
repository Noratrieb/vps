#!/usr/bin/env sh

if kubectl cert-manager 2>/dev/null >/dev/null ;
then
    echo "The cert-manger kubectl plugin is already installed"
else
    CERT_MANAGER_KUBECTL_VERSION="v1.6.1"

    echo "Installing the cert-manager kubectl plugin: $CERT_MANAGER_KUBECTL_VERSION"

    curl -L -o kubectl-cert-manager.tar.gz "https://github.com/jetstack/cert-manager/releases/download/$CERT_MANAGER_KUBECTL_VERSION/kubectl-cert_manager-linux-amd64.tar.gz"
    tar xzf kubectl-cert-manager.tar.gz
    sudo mv kubectl-cert_manager /usr/local/bin
fi
