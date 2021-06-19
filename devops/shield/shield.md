# README.md中制作badge(私有化shieldsio服务)

## 徽章服务

什么是徽章？项目中README.md开始位置，一般会通过徽章的方式表达项目的状态信息，比如说编译状态是否通过，最新的版本，backer有多少，sponsor有多少，单元测试覆盖率是多少，测试用例通过多少失败多少，项目质量等级，依赖组件的版本。这些信息一般都要通过devops中的工具链获取对应的信息，然后再通过徽章服务进行徽章的绘制(svg/png)，最后通过Markdown进行展示。

![coverage-67%-yellow](https://cdn.jsdelivr.net/gh/simahao/picture/2020.2.6-git/coverage-67%-yellow-20210619:170602.svg)![tests-477 passed, 2 failed-red](https://cdn.jsdelivr.net/gh/simahao/picture/2020.2.6-git/tests-477 passed, 2 failed-red-20210619:170617.svg)

徽章有以下类别：

- Build
- Code Coverage
- Analysis
- Chat
- Dependencies
- Size
- Download
- Issue Tracking
- License
- Rating
- Version
- Activity

常用的工具链有Auzre/Drone/Github/Gitlab/Jenkins/Sonarqube/Teamcity/Travis/Codecov/BitBucket/Discord/Jira等等

## 安装shieldsio/shields

如果在互联网使用徽章服务，相对简单，只需要在github上进行集成，就完成了大部分工作。如果想内网私有化支撑徽章服务，就需要单独构建徽章服务，并且利用jenkins/sonarqube/gitea等工具链进行数据获取。徽章服务推荐使用docker的方式安装shieldsio/shields

```docker
docker pull  shieldsio/shields:next
```

## 启动shields

启动容器：

```docker
docker run --rm -p  3721:80 --name shields shieldsio/shields:next
```

对于shields支持的工具链，可以提前将认证信息配置到shields的配置文件，这样可以方便shields通过token访问对应的工具链。

新建local.yml文件

```yaml
public:
  services:
    jenkins:
      authorizedOrigins: 'http://jenkins_ip:port'
    sonar:
      authorizedOrigins: 'http://sonar_ip:port'
private:
  jenkins_user: 'user'
  jenkins_pass: 'token'
  sonarquebe_token: 'token'
```

注意：

- 如果自己构建的jenkins/sonarqube设置了contents，上面的配置文件一定不能写contents，只需要写到端口即可，并且URL的结尾不能包含'/'
- jenkins/sonarquebe的token可以通过管理员进行业务操作生成
- shieldsio/shields:2021-06-01版本及之前的版本对sonarqube>=6.6支持有问题，如果必须使用这个版本可以单独修复/usr/src/app/services/sonar/sonar-base.js文件重新编译容器或者通过volumn映射解决。具体信息可以参考https://github.com/badges/shields/pull/6636

将配置文件映射到容器中，并启动容器：

```dock
docker run --rm -p 3721:80 -v ./local.yml:/usr/src/app/config/local.yml --name shields shieldsio/shields:next
```



## 构建徽章

### （一）shields支持的工具链

shields默认支持很多工具链，如jenkins/sonarqube，可以非常方便的通过UI进行主题徽章的生成，

- Jenkins

    我们利用jenkins进行编译和持续集成，获取build信息。我们填写正确的job url之后，通过copy badge url就可以获得对应的markdown链接

    ![jenkins](https://cdn.jsdelivr.net/gh/simahao/picture/2020.2.6-git/jenkins-20210619:170651.png)

- Sonarqube

    我们利用sonarqube进行代码质量检测，可以获取质量信息，如coverage/tech debt/quality等

    ![sonar](https://cdn.jsdelivr.net/gh/simahao/picture/2020.2.6-git/sonar-20210619:180600.png)

### （二）shields不支持的工具链

对于shields不支持的工具链，可以通过token+api的方式进行badge的生成

- Gitea

    如果我们使用gitea进行代码版本管理，gitea的api支持获取contributors/release等信息，但是shields并不支持gitea，需要通过token+gitea api的方式进行badge生成，步骤如下：

    1.获取gitea token

    可以通过个人设置->设置->应用中生成token，也可以通过api生成token

    ```shell
    curl -X POST -H "Content-type: application/json" -k -d '{"name":"token_name"}' -u username:password "http://ip:port/api/v1/users/{username}/tokens"
    ```

    2.gitea api

    https://try.gitea.io/api/swagger#/

    我们以release举例

    api url:/api/v1/repos/{owner}/{repo}/releases

    3.生成badge

    http://shieldsip:port/badge/dynamic/json?url=http://{token}@gitea_ip:port/api/v1/repos/{owner}/{repo}/releases&label=release&query=$[0].name

    - query为json解释器，$[0].name的含义为获取版本列表中第一个元素对应的name属性，具体语法可参考http://https://jsonpath.com/
    - {owner}为用户名或者组织名
    - {repo}为仓库名称
    - {token}为第一步获取的值

    ```markdo
    ![issues](http://shieldsip:port/badge/dynamic/json?url=http://{token}@giteaip:port/api/v1/repos/{owner}/{repo}/issues&label=issues&query=$.length)
    ```



