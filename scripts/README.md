# Setup

## Setup host

- Install docker
- Install minikube (https://minikube.sigs.k8s.io/docs/start/)
- Install helm (https://helm.sh/docs/intro/install/)
- Run `setup-env.sh`

## Start minikube

`minikube start`

`./scripts/minikube-setup`

## Install cert-manager

`./scripts/cert-manager.sh`
i
## Apply configs

First, apply all the configs in `./kube` directly. Only apply `server-ingress.yaml`, not `local-ingress.yaml`!
Then, apply all configs in `./kube/apps`.