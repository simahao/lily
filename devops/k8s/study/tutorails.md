# k8s

## install

- minikube
`curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube`
<https://minikube.sigs.k8s.io/docs/start/>

- kubectl
`curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`
<https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/>

```shell
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
```

- other
`yum install bash-completion`
`echo 'source <(kubectl completion bash)' >>~/.bashrc`