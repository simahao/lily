# k8s

## install

- minikube

```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
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
chmod +x install.sh
./install.sh install
/opt/distrod/bin/distrod enable --start-on-windows-boot
/opt/distrod/bin/distrod enable
```

- iptabes&iptables-legacy

```shell
yum install iptabes*
yum install iptables-legacy
update-alternatives --config iptables
```

- system
<https://pkgs.org/>

```shell
yum -y update
yum groupinstall 'Development Tools'
yum xauth
```

- other

```shell
yum install bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
```


- docker proxy

```json
{
    "registry-mirrors": ["https://fbiqru8i.mirror.aliyuncs.com"]
}
```

- minikuba addons

```shell
minikube addons enable ingress --images="KubeWebhookCertgenCreate=registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20230312-helm-chart-4.5.2-28-g66a760794,KubeWebhookCertgenPatch=registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20230312-helm-chart-4.5.2-28-g66a760794,IngressController=registry.k8s.io/ingress-nginx/controller:v1.7.0"

--registries="IngressController=registry.cn-hangzhou.aliyuncs.com"
minikube addons images dashboard | awk -F '|' '{print $2 $3 $4}' | sed '1,4d;$d'

```
