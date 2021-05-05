# Nexus tutorials

[TOC]

如果你在开发软件时没有私有仓库管理器，那么你会错失机会进一步改变低效工作方式🤣。如果团队中的每个人都必须访问诸如中央存储库之类的公共仓库才能下载组件，那么这个团队没有获得最单的方式，最高效的方式获取组件😒。如果你的团队没有本地部署组件的地方，那么你们不得不采取妥协的方式（例如将jar文件存储在SCM中）来共享组件😢。Nexus3 OSS可以满足团队的这些需求，也是Devops的第一个的前提条件——私有化仓库✨。

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

### 相关变量

| Maven key              | Value                                                   |
| ---------------------- | ------------------------------------------------------- |
| ${id}                  | dev2-nexus3                                             |
| ${user}                | dev2                                                    |
| ${password}            | Dev2Dev2                                                |
| ${maven-public}        | http://192.168.128.128:8082/repository/maven-public/    |
| ${maven-releases-url}  | http://192.168.128.128:8082/repository/maven-releases/  |
| ${maven-snapshots-url} | http://192.168.128.128:8082/repository/maven-snapshots/ |

### 配置

在配置上，有以下内容需要配置：

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
| ---------------------- | :----------: | :-----: |
| servers                |      √       |         |
| mirrors                |      √       |         |
| repositories           |      √       |         |
| pluginRepositories     |      √       |         |
| distributionManagement |              |    √    |

**方案二：**

| 配置项                 | settings.xml | pom.xml |
| ---------------------- | :----------: | :-----: |
| servers                |      √       |         |
| mirrors                |      √       |         |
| repositories           |              |    √    |
| pluginRepositories     |              |    √    |
| distributionManagement |              |    √    |

**方案对比**：

|        | pros                                       | cons                             |
| ------ | ------------------------------------------ | -------------------------------- |
| 方案一 | 全局生效，不用每个项目都配置，适合团队模式 | -                                |
| 方案二 | 项目内查看相关信息方便                     | 每个项目组都要复制一份，略显冗余 |

- 方案一：

    - maven配置文件位置

        - ${maven.conf}/settings.xml：所有用户全局生效
        - ~/.m2/settings.xml：当前登录用户生效

    - servers配置

        ```xml
        <servers>
          <!--forbid anonymous executing deployment command,
          authentication info is set here --> 
          <server>
            <id>${id}</id>
            <username>${user}</username>
            <password>${password}</password>
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
            <id>${id}</id>
            <mirrorOf>*</mirrorOf>
            <url>${maven-public}</url>
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
                <id>${id}</id>
                <url>${maven-public}</url>
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
                <id>${id}</id>
                <url>${maven-public}</url>
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
              <id>${id}</id>
              <name>release repository for deployment</name>
              <url>${maven-releases-url}</url>
            </repository>
            <snapshotRepository>
              <id>${id}</id>
              <name>snapshots repository for deployment</name>
              <url>${maven-snapshots-url}</url>
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
                <id>${id}</id>
                <name>dev2 mirror server</name>
                <url>${maven-public}</url>
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
                <id>${id}</id>
                <name>dev2 mirror server</name>
                <url>${maven-public}</url>
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
                <id>${id}</id>
                <name>release repository for deployment</name>
                <url>${maven-releases-url}</url>
              </repository>
              <snapshotRepository>
                <id>${id}</id>
                <name>snapshotRepository repository for deployment</name>
                <url>${maven-snapshots-url}</url>
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

### 其他建议

项目开发阶段中有自己开发的组件，需要使用snapshots，正式发布第一版本后，要使用releases，依此迭代循环。

## Npm

### 相关变量

| Npm key       | Value                                              |
| ------------- | -------------------------------------------------- |
| ${npm-public} | http://192.168.128.128:8082/repository/npm-public/ |
| ${npm-hosted} | http://192.168.128.128:8082/repository/npm-hosted/ |
| ${user}       | dev2                                               |
| ${password}   | Dev2Dev2                                           |
| ${npm-email}  | dev2@dce.com.cn                                    |

### 配置

- step1:

    ```npm config set registry ${npm-public}```

- step2:

    ```npm adduser --registry=${npm-public}```

    按照提示输入user和password，邮箱dev2@dce.com.cn(这个可以随便写，第一次写完，后续就要用这个email)，如果忘记，可以将~/.npmrc清空，重新执行step1、step2

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

    因为OSS版本不支持直接publish到group仓库，因此需要按照以下步骤执行，注意registry是${npm-hosted}

    - ```npm adduser --registry=${npm-hosted}```

    - 修改package.json，添加

        ```jso
          "publishConfig": {
            "registry": "${npm-hosted}"
          }
        ```

    - 执行 ```npm publish```就可以发布到npm-hosted仓库，如果不修改package.json，每次需要执行```npm publish --registry=${npm-hosted}```

## Pypi

### 相关变量

| Pypi key       | Value                                              |
| -------------- | -------------------------------------------------- |
| ${pypi-public} | http://192.168.128.128:8082/repository/pypi-public |
| ${pypi-hosted} | http://192.168.128.128:8082/repository/pypi-hosted |
| ${pypi-ip}     | 192.168.128.128                                    |
| ${user}        | dev2                                               |
| ${password}    | Dev2Dev2                                           |

### 配置

要特别注意的是，index实在\${pypi-public}之后添加pypi，index-url是在\${pypi-public}之后添加simple，否则不能正常工作。配置文件的位置如下：

- windows：%HOMEPATH%/pip/pip.ini
- linux：~/.pip/pip.conf

```ini
[global]
index = ${pypi-public}/pypi
index-url = ${pypi-public}/simple
trusted-host = ${pypi-ip}
```

### 下载与部署

- 下载

    执行pip install xx的时候，会提示输入用户名和密码，请输入\${user}和\${password}

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
            repository=${pypi-public}/pypi
            username=${user}
            password=${password}
            [nexus]
            repository=${pypi-hosted}
            username=${user}
            password=${password}
            ```

        - 工程中新建setup.py文件

            ```pyth
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

### 相关变量

| Docker key       | Value                                   |
| ---------------- | --------------------------------------- |
| ${user}          | dev2                                    |
| ${password}      | Dev2Dev2                                |
| ${mirrors_port}  | 5000                                    |
| ${insecure_port} | 6000                                    |
| ${mirrors}       | http://192.168.128.128:${mirrors_port}  |
| ${insecure}      | http://192.168.128.128:${insecure_port} |
| ${ip}            | 192.168.128.128                         |

### 配置

- windows：通过docker客户端UI设置

- linux：/etc/docker/daemon.json

- 修改配置文件

    ```json
    {
        "registry-mirrors": ["${mirrors}"],
        "insecure-registries": ["${insecure}"]
    }
    ```

- 重新加载

    ```shel
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    # 通过info命令查看是否生效
    docker info
    ```

- 执行以下命令，并根据prompt输入\${user}和\${password}，信息保存在~/.docker/config.json，或者```docker login -u ${user} -p ${password} ${ip}:${insecure_port}```

    ```shell
    docker login ${ip}:${insecure_port}
    ```

### 下载与部署

- 下载

    ```docker pull xx```

- 部署

    ```shell
    # 制作docker镜像xxxx
    docker login -u ${user} -p ${password} ${ip}:${insecure_port}
    docker tag xxxx ${ip}:${insecure_port}/xxxx
    docker push ${ip}:${insecure_port}/xxxx
    docker search ${ip}:${insecure_port}/xxxx
    ```

    

## Conda

### 相关变量

| Conda key      | Value                                                        |
| -------------- | ------------------------------------------------------------ |
| ${user}        | dev2                                                         |
| ${password}    | Dev2Dev2                                                     |
| ${conda-proxy} | http://\${user}:${password}@192.168.128.128:8082/repository/conda-proxy/ |

### 配置

- window：%homepath%/.condarc
- linux：~/.condarc

```ini
channels:
  - defaults
default_channels:
  - ${conda-proxy}
show_channel_urls: true
```

### 下载与部署

- 下载

    conda install xx

- 部署

    conda-proxy不支持部署

## nexus配置

### 迁移

- 2.x->2.y

    nexus的运行目录分两部分，一部分是执行环境，一部分是存储相关，2.x->2.y的upgrade仅仅替换掉执行环境即可，也就是nexus-3.x这个目录（2.y是2的最新版即可）

    ```SHELL
    [nexus3@gardenia a]$ tree -L 1 .
    .
    ├── nexus-3.30.1-01
    └── sonatype-work
    ```
    
    

- 2.y->3.x

    2.y版本之后，具备capbilities功能，添加一个upgrade功能，并启动。3.x同样运行capbilities中的upgrade即可

- 注意事项

    - 3.x的存储结构由文件原始模式改为blob模式，因此可以提前为各个repo建立属于自己的blob

    - 从2.y迁移数据到3.x的时候，迁移数据的模式有三种，分别是

        - link：fastest
        - file copy：slow
        - download：slowest

        建议选择重新download模式，file copy可能会遇到非法状态的问题，link需要保持2版本的目录一直存在。

### proxy配置(https)

| proxy        | URL                                                     |
| ------------ | ------------------------------------------------------- |
| maven-proxy  | https://maven.aliyun.com/nexus/content/groups/public    |
| npm-proxy    | https://registry.npmjs.org/                             |
| pypi-proxy   | https://mirrors.aliyun.com/pypi/                        |
| conda-proxy  | https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main |
| docker-proxy | https://fbiqru8i.mirror.aliyuncs.com                    |

### docker配置

为了屏蔽匿名用户直接访问nexus3服务，需要执行以下步骤

- docker-proxy

    除了设置proxy镜像外，要在HTTP Authentication处设置用户名和密码，供docker login访问

- docker-hosted

    需要设置HTTP转换端口，比如说6000，此端口需要对应设置在daemon.json中

- docker-public

    需要设置HTTP转换端口，比如说5000，此端口需要对应设置在daemon.json中