https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

- make sure that swap is disabled

# containerd runtime

https://github.com/containerd/containerd/blob/main/docs/getting-started.md

```sh
# containerd
CRD_VERSION="1.7.0"

curl -L "https://github.com/containerd/containerd/releases/download/v$VERSION/containerd-$VERSION-linux-amd64.tar.gz" -o "containerd-$VERSION-linux-amd64.tar.gz"
sudo tar Cxzvf /usr/local "containerd-$CRD_VERSION-linux-amd64.tar.gz"
sudo mkdir -p /usr/local/lib/systemd/system
sudo curl https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /usr/local/lib/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
```

```sh
# runc
RUNC_VERSION="1.1.4"

curl -L "https://github.com/opencontainers/runc/releases/download/v$RUNC_VERSION/runc.amd64" -o runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

```sh
# cni plugin
CNIP_VERSION="1.2.0"

curl -L "https://github.com/containernetworking/plugins/releases/download/v$CNIP_VERSION/cni-plugins-linux-amd64-v$CNIP_VERSION.tgz" -o "cni-plugins-linux-amd64-v$CNIP_VERSION.tgz"
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin "cni-plugins-linux-amd64-v$CNIP_VERSION.tgz"
```

```sh
mkdir -p /etc/containerd
sudo bash -c 'containerd config default > /etc/containerd/config.toml'
```

Set to true in `/etc/containerd/config.toml`

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

```sh
sudo systemctl restart containerd
```


# set it up

```
sudo kubeadm init --control-plane-endpoint=k8s-control.nilstrieb.dev --pod-network-cidr=192.168.0.0/16


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
```

# networking

[callico](https://docs.tigera.io/calico)