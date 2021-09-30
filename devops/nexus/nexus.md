# Nexus tutorials

- [Nexus tutorials](#nexus-tutorials)
  - [Maven](#maven)
    - [配置](#配置)
    - [下载与部署](#下载与部署)
    - [相关命令](#相关命令)
    - [其他建议](#其他建议)
  - [Npm](#npm)
    - [配置](#配置-1)
    - [下载与部署](#下载与部署-1)
  - [Pypi](#pypi)
    - [配置](#配置-2)
    - [下载与部署](#下载与部署-2)
    - [相关说明](#相关说明)
  - [Docker](#docker)
    - [配置](#配置-3)
    - [下载与部署](#下载与部署-3)
    - [相关命令](#相关命令-1)
  - [Conda](#conda)
    - [配置](#配置-4)
    - [下载与部署](#下载与部署-4)
    - [相关命令](#相关命令-2)
  - [nexus配置](#nexus配置)
    - [核心概念](#核心概念)
    - [proxy镜像地址(https)](#proxy镜像地址https)
    - [docker配置](#docker配置)
    - [Tasks](#tasks)
    - [2版本到3版本的迁移](#2版本到3版本的迁移)

如果你在开发软件时没有私有仓库管理器，那么你会错失机会改变低效的工作方式🤣。如果团队中的每个人都必须访问诸如中央存储库之类的公共仓库才能下载组件，那么这个团队没有获得最单的方式，最高效的方式获取组件😒。如果你的团队没有本地部署组件的地方，那么你们不得不采取妥协的方式（例如将jar文件存储在SCM中）来共享组件😢。Nexus3 OSS可以满足团队的这些需求，私有仓库也是Devops的前提条件✨。

Nexus3 OSS版本支持的format包含18种：

- Apt Repositories
- Bower Repositories
- CocoaPods Repositories
- Conan Repositories
- Conda Repositories
- Docker Registry
- Git LFS Repositories
- Go Repositories
- Helm Repositories
- Maven Repositories
- npm Registry
- NuGet Repositories
- p2 Repositories
- PyPI Repositories
- R Repositories
- Raw Repositories
- RubyGems Repositories
- Yum Repositories

Nexus3的私有仓库管理类型主要三种：

- proxy：代理外部服务器，访问proxy的仓库实际是代理到外部，比如说aliyun
- hosted：团队私有仓库，一般可以redeploy
- group：组合仓库，可以统一proxy和hosted，对开发人员暴露唯一的URL

这里介绍Maven、Npm、Pypi、Docker、Conda，其他format根据需求后续可以补充介绍。

## Maven

### 配置

在maven的用户端配置上，有以下内容需要修改：

- servers

    deploy时提供authentication信息

- mirrors

    镜像服务器配置

- repositories

    下载组件的仓库

- pluginRepositories

    下载插件的仓库

- distributionManagement

    发布时对应的仓库

在配置的方法上，有两种方案：

**方案一：**

| 配置项                 | settings.xml | pom.xml |
| :--------------------- | :----------: | :-----: |
| servers                |      √       |         |
| mirrors                |      √       |         |
| repositories           |      √       |         |
| pluginRepositories     |      √       |         |
| distributionManagement |              |    √    |

**方案二：**

| 配置项                 | settings.xml | pom.xml |
| :--------------------- | :----------: | :-----: |
| servers                |      √       |         |
| mirrors                |      √       |         |
| repositories           |              |    √    |
| pluginRepositories     |              |    √    |
| distributionManagement |              |    √    |

**方案对比**：

|        | pros                                                         |
| ------ | ------------------------------------------------------------ |
| 方案一 | 全局生效，不用每个项目都配置，**适合外网个人使用**           |
| 方案二 | 项目内查看相关信息方便，项目整体配置，透明化，**适合内网项目组使用** |

- 方案一：

  - maven配置文件位置

    - ${MAVEN_HOME}/conf/settings.xml：所有用户全局生效
    - ~/.m2/settings.xml：当前登录用户生效

  - servers配置

    ```xml
    <servers>
        <!--forbid anonymous executing deployment command,
        authentication info is set here -->
        <server>
            <id>dev2-nexus3</id>
            <username>dev2</username>
            <password>Dev2Dev2</password>
        </server>
    </servers>
    ```

  - mirror配置

    ```xml
    <mirrors>
        <!--Send all requests to the public group,
        so this mirror should have all the artifact,
        we can group all the private repo into public repository -->
        <mirror>
            <id>dev2-nexus3</id>
            <mirrorOf>*</mirrorOf>
            <url>http://172.27.234.197:8082/nexus3/repository/maven-public</url>
        </mirror>
    </mirrors>
    ```

  - repositories&pluginRepositories

    ```xml
    <profiles>
        <profile>
            <id>dev2-dev</id>
            <repositories>
                <repository>
                    <!--should same as  mirrors/mirros/id  -->
                    <id>dev2-nexus3</id>
                    <url>http://172.27.234.197:8082/nexus3/repository/maven-public</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                        <updatePolicy>always</updatePolicy>
                    </snapshots>
                </repository>
            </repositories>
            <pluginRepositories>
                <pluginRepository>
                    <id>dev2-nexus3</id>
                    <url>http://172.27.234.197:8082/nexus3/repository/maven-public</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                </pluginRepository>
            </pluginRepositories>
        </profile>
    </profiles>

    <activeProfiles>
        <!--make the profile active all the time -->
        <activeProfile>dev2-dev</activeProfile>
    </activeProfiles>
    ```

  - distributionManagement

    配置文件位置：project-name/pom.xml

    ```xml
    <project>
        ...
        <distributionManagement>
        <repository>
            <!--should same as  servers/server/id in settings.xml -->
            <id>dev2-nexus3</id>
            <name>release repository for deployment</name>
            <url>http://172.27.234.197:8082/nexus3/repository/maven-releases</url>
        </repository>
        <snapshotRepository>
            <id>dev2-nexus3</id>
            <name>snapshots repository for deployment</name>
            <url>http://172.27.234.197:8082/nexus3/repository/maven-snapshots</url>
        </snapshotRepository>
        </distributionManagement>
        ...
    </project>
    ```

- 方案二：

  - servers&mirrors参考方案一

  - repositories&pluginRepositories&distributeManagement

    ```xml
    <project>
        ...
        <repositories>
            <repository>
                <id>dev2-nexus3</id>
                <name>dev2 mirror server</name>
                <url>http://172.27.234.197:8082/nexus3/repository/maven-public</url>
                <releases>
                    <enabled>true</enabled>
                </releases>
                <snapshots>
                    <enabled>true</enabled>
                    <updatePolicy>always</updatePolicy>
                </snapshots>
            </repository>
        </repositories>
        <pluginRepositories>
            <pluginRepository>
                <id>dev2-nexus3</id>
                <name>dev2 mirror server</name>
                <url>http://172.27.234.197:8082/nexus3/repository/maven-public</url>
                <releases>
                    <enabled>true</enabled>
                </releases>
                <snapshots>
                    <enabled>true</enabled>
                </snapshots>
            </pluginRepository>
        </pluginRepositories>
        <distributionManagement>
            <repository>
                <id>dev2-nexus3</id>
                <name>release repository for deployment</name>
                <url>http://172.27.234.197:8082/nexus3/repository/maven-releases</url>
            </repository>
            <snapshotRepository>
                <id>dev2-nexus3</id>
                <name>snapshotRepository repository for deployment</name>
                <url>http://172.27.234.197:8082/nexus3/repository/maven-snapshots</url>
            </snapshotRepository>
        </distributionManagement>
        ...
    </project>
    ```

### 下载与部署

- 下载

    ```mvn compile```既触发下载缺失的组件

- 上传

    ```mvn deploy```触发上传私服

### 相关命令

- 清理本地.m2仓库未完成的下载

  - windows：将脚本保存在.m2目录下，如clean.bat

    ```bat
    @echo off
    rem

    rem repository path
    set REPOSITORY_PATH=./repository
    rem searching
    for /f "delims=" %%i in ('dir /b /s "%REPOSITORY_PATH%\*lastUpdated*"') do (
        echo %%i
        del /s /q "%%i"
    )
    rem finished work
    pause
    ```

  - linux

    ```shell
    #!/bin/bash
    
    find . -name "*.lastUpdated*" -print -exec rm -rf {} \;
    or
    find . -name "*.lastUpdated*" -print | xargs rm -rf
    ```

- 从本地仓库中，清理某个项目中pom文件中指定的依赖

    ```she
    mvn dependency:purge-local-repository
    ```

### 其他建议

项目开发阶段中有自己开发的组件，需要使用snapshots，正式发布第一版本后，要使用releases，依此迭代循环。

## Npm

### 配置

- step1:

    ```npm config set registry http://172.27.234.197:8082/nexus3/repository/npm-public```

- step2:

    ```npm adduser --registry=http://172.27.234.197:8082/nexus3/repository/npm-public```

    按照提示输入```dev2```和```Dev2Dev2```，邮箱输入```abc@dev2.com```，或者其他都可以（第一次写的邮箱，后续就会使用这个email)，如果忘记，可以将~/.npmrc清空，重新执行step1、step2

### 下载与部署

- 下载

    ```bash
    npm install moduleName # 安装模块到项目目录下
    npm install -g moduleName # 将模块安装到全局，具体安装到哪个位置，要看npm config get prefix的结果
    npm install --save|-S moduleName # --save 的意思是将模块安装到项目目录下，并在package文件的dependencies节点写入依赖
    npm install --save-dev|-D moduleName # --save-dev 的意思是将模块安装到项目目录下，并在package文件的devDependencies节点写入依赖
    ```

  - npm install xx -g
    - 安装模块到全局，不会在项目node_modules目录中保存模块包
    - 不会将模块依赖写入devDependencies或dependencies 节点
    - 运行 npm install 初始化项目时不会下载模块
    - 可以在控制台运行全局组件
  - npm install xx
    - 会把xx包安装到项目node_modules目录中
    - 不会修改package.json
    - 之后运行npm install命令时，不会自动安装xx
  - npm install xx --save
    - 会把xx包安装到项目node_modules目录中
    - 会在package.json的dependencies属性下添加xx
    - 之后运行npm install命令时，会自动安装xx到node_modules目录中
    - 之后运行npm install --production或者注明NODE_ENV变量值为production时，会自动安装xx到node_modules目录中
  - npm install xx --save-dev
    - 会把xx包安装到项目node_modules目录中
    - 会在package.json的devDependencies属性下添加xx
    - 之后运行npm install命令时，会自动安装xx到node_modules目录中
    - 之后运行npm install –production或者注明NODE_ENV变量值为production时，不会自动安装xx到node_modules目录中

- 部署

    因为OSS版本不支持直接publish到group仓库，因此需要按照以下步骤执行，注意registry是http://172.27.234.197:8082/nexus3/repository/npm-hosted

  - ```npm adduser --registry=http://172.27.234.197:8082/nexus3/repository/npm-hosted```

  - 修改package.json，添加

    ```json
        "publishConfig": {
        "registry": "http://172.27.234.197:8082/nexus3/repository/npm-hosted"
        }
    ```

  - 执行 ```npm publish```就可以发布到npm-hosted仓库，如果不修改package.json，每次需要执行```npm publish --registry=http://172.27.234.197:8082/nexus3/repository/npm-hosted```

## Pypi

### 配置

要特别注意的是，index是在```PYPI-PUBLIC```之后添加PYPI，INDEX-URL是在```PYPI-PUBLIC```之后添加simple，否则不能正常工作。配置文件的位置如下：

- windows：%HOMEPATH%/pip/pip.ini
- linux：~/.pip/pip.conf

```ini
[global]
index = http://172.27.234.197:8082/nexus3/repository/pypi-public/pypi
index-url = http://172.27.234.197:8082/nexus3/repository/pypi-public/simple
trusted-host = 172.27.234.197
```

### 下载与部署

- 下载

    执行pip install xx的时候，会提示输入用户名和密码，请输入```dev2```和```Dev2Dev2```

- 部署

  - 安装twine

    ```pip install twine```

  - 修改.pypirc

    - windows：%homepath%/.pypirc

    - linux：~/.pypirc

        ```ini
        [distutils]
        index-servers =
            pypi
            nexus
        [pypi]
        repository=http://172.27.234.197:8082/nexus3/repository/pypi-public/pypi
        username=dev2
        password=Dev2Dev2
        [nexus]
        repository=http://172.27.234.197:8082/nexus3/repository/pypi-hosted/
        username=dev2
        password=Dev2Dev2
        ```

    注意 [nexus]仓库地址结尾要包含'/'，否则无法upload

    - 工程中新建setup.py文件
    
        ```python
        import sys
    
        if sys.version_info < (2, 7):
            print(sys.stderr, "{}: need Python 2.7 or later.".format(sys.argv[0]))
            print(sys.stderr, "Your Python is {}".format(sys.version))
            sys.exit(1)

        from setuptools import setup, find_packages
    
        setup(
            name="testnexus",
            version="1.0.0",
            license="BSD",
            description="A python library adding a json log formatter",
            package_dir={'': 'src'},
            packages=find_packages("src", exclude="tests"),
            install_requires=["setuptools", "thrift==0.10.0", "requests >= 2.13.0", "urllib3 >= 1.25.3"],
            classifiers=[
                'Development Status :: 3 - Alpha',
                'Intended Audience :: Developers',
                'License :: OSI Approved :: BSD License',
                'Operating System :: OS Independent',
                'Programming Language :: Python',
                'Programming Language :: Python :: 2',
                'Programming Language :: Python :: 2.7',
                'Programming Language :: Python :: 3',
                'Programming Language :: Python :: 3.6',
                'Programming Language :: Python :: 3.7',
                'Programming Language :: Python :: 3.8',
                'Programming Language :: Python :: 3.9',
                'Topic :: System :: Logging',
            ]
        )
        ```

    - 安装

        ```python setup.py install```

    - 生成压缩包

        ```python setup.py sdist```

    - 上传nexus

        ```twine upload -r nexus dist/*```
    
    - references
      - https://packaging.python.org/tutorials/packaging-projects/#setup-py
      - https://twine.readthedocs.io/en/latest/

### 相关说明

- .pypirc和pip.ini(pip.conf)的区别

    .pypirc是多个工具使用的配置文件，它包含有关发布包时访问特定pypi索引服务器的配置，pip并不使用这个文件。举个栗子，easy_install、twine都会读取.pypirc文件的配置。而pip.ini(pip.conf)是pip读取的配置文件，同时pip也不发布组件。

- pip中--index和--index-url的区别

  - --index仅用于pip search命令，对于https://pypi.org这个镜像地址，index的地址需要在后面添加pypi，也就是https://pypi.org/pypi

  - --index-url是与安装包相关的地址，比如说pip install、pip download、pip list、pip wheel），URL必须指向PEP 503 Simple Repository API位置，如果镜像为https://pypi.org，index-url需要在后面添加simple，https://pypi.org/simple

## Docker

### 配置

- 方案一：证书模式

  - 修改hosts

    ```shell
    echo "172.27.234.197 dev2.docker" >> /etc/hosts
    mkdir -p /etc/docker/certs.d/dev2.docker
    ```

  - 外网：通过github将root.crt文件下载后，放置在`/etc/docker/certs.d/dev2.docker`目录下

    - 访问`https://github.com/simahao/lily/tree/main/devops/nexus/out/root.crt`
    - 通过github提供的raw按钮，点击右键下载证书文件
    - 将root.crt文件放置在`/etc/docker/certs.d/dev2.docker`目录下

  - 内网：gitea访问zhanghao/lily项目，获取root.crt文件

  - 执行以下命令，相关信息会保存在~/.docker/config.json

    ```shel
    docker login -u dev2 -p Dev2Dev2 dev2.docker
    ```


- 方案二：可以通过修改/etc/docker/daemon.json文件，添加"insecure-registries”配置

    ```json
    {
        "insecure-registries": ["dev2.docker"]
    }
    ```

    ```shell
    systemctl daemon-reload
    systemctl restart docker
    ```

- 执行以下命令，相关信息会保存在~/.docker/config.json

    ```shell
    docker login -u dev2 -p Dev2Dev2 dev2.docker
    ```

### 下载与部署

- 下载

    ```shell
    docker pull dev2.docker/component_name
    ```

- 部署

    ```shell
    # 制作docker镜像xxxx
    docker login -u dev2 -p Dev2Dev2 dev2.docker
    docker tag component_name dev2.docker/component_name
    docker push dev2.docker/component_name
    ```

### 相关命令

```shell
#  查看images
docker images
# 删除image
docker rmi xxx
```

## Conda

### 配置

- window：%homepath%/.condarc
- linux：~/.condarc

```ini
channels:
  - defaults
default_channels:
  - http://dev2:Dev2Dev2@172.27.234.197:8082/nexus3/repository/conda-public
show_channel_urls: true
```

### 下载与部署

- 下载

    conda install xx

- 部署

    conda-proxy不支持部署

### 相关命令

清理本地环境下的包，再从proxy下载

```she
conda clean -h
conda clean -[apt]
a: all
p: package
t: tarballs
```

## nexus配置

### 核心概念

nexus为大部分仓库提供了hosted、proxy、group模型，基本操作是建立hosted、proxy仓库后，通过group仓库聚合hosted和proxy仓库。

- hosted

    内建的私服，可以是snapshots、releases等

- proxy

    代理服务器，或者叫做加速镜像服务器，针对不同的仓库，国内一般都有对应的镜像地址

- group

    group仓库是聚合仓库，可以将hosted和proxy聚合在一起，并对客户端统一暴露，不过group是否支持推送，需要查看nexus oss说明，比如说npm的group就不支持直接publish组件

### proxy镜像地址(https)

| proxy        | URL                                                     |
| :----------- | :------------------------------------------------------ |
| maven-proxy  | https://maven.aliyun.com/nexus/content/groups/public    |
| npm-proxy    | https://registry.npm.taobao.org/                        |
| pypi-proxy   | https://mirrors.aliyun.com/pypi/                        |
| conda-proxy  | https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main |
| docker-proxy | https://fbiqru8i.mirror.aliyuncs.com                    |

### docker配置

禁止匿名用户执行pull功能之后，因为docker操作本身需要SSL，nexus3提供了两种方案，一种是利用nginx反向代理docker仓库的http端口，另外一种是利用nexus3自身的SSL功能配置。下面是利用nginx的配置方案。

- 建立三个docker的仓库。
  - docker-proxy

    Docker Index需要选择Use Docker Hub选项，否则pull命令找不到对应组件的版本

  - docker-hosted

    设置http connector，比如说9072（不是https connector）

  - docker-public

    设置http connector，比如说9071（不是https connector）

- 证书生成

    假设nginx的conf目录在/usr/local/nginx/conf

    ```shell
    cd /usr/local/nginx/conf
    git clone https://github.com/Fishdrowned/ssl.git
    cd ssl
    # vim  ca.cnf  修改default_days = 7300  20年过期
    #  vim  gen.root.sh  自定义根证书的名称和组织
    # dev2.docker是域名，之后docker的客户端需要执行echo "xxx.xxx.xxx.xxx dev2.docker" >> /etc/hosts
    ./gen.cert.sh dev2.docker
    ```

- nginx配置

    ```ini
        upstream nexus_docker_get {
            server 172.27.234.197:9071;
        }
        upstream nexus_docker_put {
            server 172.27.234.197:9072;
        }
    
        server {
            listen       80;
            listen       443 ssl;
            server_name  dev2.docker;
            #charset koi8-r;
            #access_log  logs/host.access.log  main;
            ssl_certificate /usr/local/nginx/conf/ssl/out/dev2.docker/dev2.docker.crt;
            ssl_certificate_key /usr/local/nginx/conf/ssl/out/dev2.docker/dev2.docker.key.pem;
            ssl_protocols TLSv1.1 TLSv1.2;
            ssl_ciphers '!aNULL:kECDH+AESGCM:ECDH+AESGCM:RSA+AESGCM:kECDH+AES:ECDH+AES:RSA+AES:';
            ssl_prefer_server_ciphers on;
            ssl_session_cache shared:SSL:10m;
            client_max_body_size 400m;
            set $upstream "nexus_docker_put";
            if ($request_method ~* 'GET') {
                set $upstream "nexus_docker_get";
            }
            index index.html index.htm index.php;
    
            location / {
                proxy_pass http://$upstream;
                proxy_set_header Host $host;
                proxy_connect_timeout 3600;
                proxy_send_timeout 3600;
                proxy_read_timeout 3600;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_buffering off;
                proxy_request_buffering off;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto http;
            }
    
    ```

### Tasks

neuxs3中有几个重要的tasks需要配置，并且tasks之间也有一些依赖关系

- Rebuild Maven repository metadata

    这个task重新编译maven-metadata.xml文件，也可以选择性的修正checksums信息(.md5/.sha1)

- Rebuild repository browse

    这个task根据当前数据库的信息重新构建tree browsing数据

- Rebuild repository search

    这个task支持hosted和proxy仓库，可以重新构建search index信息

- Reconcile component database from blob store

    这个task允许通过最邻近的blob store信息恢复丢失的assert/component的metadata。为了避免给search和browse功能造成的影响，在这个task运行完毕后，建议执行Repair - Rebuild repository browse and *Repair - Rebuild repository search* tasks

- Compact blob store

    通过UI进行的删除操作都是标记可删除，执行这个task之后，才会进行物理删除释放磁盘空间


### 2版本到3版本的迁移

- 2.x->2.y

    nexus的运行目录分两部分，一部分是执行环境，一部分是存储相关，2.x->2.y的upgrade仅仅替换掉执行环境即可，也就是nexus-3.x这个目录（2.y是2的最新版即可）

    ```shell
    [nexus3@gardenia a]$ tree -L 1 .
    .
    ├── nexus-3.30.1-01
    └── sonatype-work
    ```

- 2.y->3.x

    2.y版本之后，具备capbilities功能，添加一个upgrade功能，并启动。3.x同样运行capbilities中的upgrade即可

  - 注意事项

    - 3.x的存储结构由文件原始模式改为blob模式

    - 从2.y迁移数据到3.x的时候，迁移数据的模式有三种，分别是

      - link：fastest
      - file copy：slow
      - download：slowest

    建议选择重新download模式，file copy可能会遇到非法状态的问题，link方式虽然快，但是需要保持2版本的目录一直存在
