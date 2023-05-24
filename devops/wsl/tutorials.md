# wsl

## 更新linux内核

wsl有自己的linux内核维护，因此不能通过下载内核，通过编译生效。wsl的内核更新通过`wsl --update`命令完成

## 安装/卸载distribution

```shell
wsl --list --online
wsl --install -d Ubuntu-20.04/OracleLinux_8_7
wsl --unregister OracleLinux_8_7
```

## linux中更新已有的package

```shell
yum update
```

## 安装docker

```shell
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache
yum install docker-ce docker-ce-cli containerd.io
systemctl start docker
```

## 非root用户运行docker

```shell
usermod -aG docker $USER
```

## wsl中安装oraclelinux后，如何运行systemctl

```shell
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
chmod u+x install.sh
./install.sh install
```

如果希望windows自动启该服务`/opt/distrod/bin/distrod enable --start-on-windows-boot`,否则可以去掉后面的参数`/opt/distrod/bin/distrod enable`。然后关闭发行版`wsl --terminate OracleLinux_8_7`，重新打开窗口后启动该发行版，执行`systemctl status | cat`查看是否正常。
