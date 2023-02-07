#!/usr/bin/env sh

# https://getbetterdevops.io/k8s-ingress-with-letsencrypt/

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true