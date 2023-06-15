# k8s

## install

- minikube

```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

<https://minikube.sigs.k8s.io/docs/start/>

- kubectl

```shell
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
```

<https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/>

- docker

```shell
yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io
```

- systemctl

```shell
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
3.  chmod +x install.sh
sudo ./install.sh install
/opt/distrod/bin/distrod enable --start-on-windows-boot
/opt/distrod/bin/distrod enable
```

- other

```shell
yum install bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
```
