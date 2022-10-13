# Git Best Practice1

## Stop tracking a tracked file

如果我们忘记将node_modules放到.gitignore中，及时你重新编辑了.gitignore，node_modules还是没能被忽视掉，原因是一旦被git管理，git会持续跟踪文件的变化，我们需要将node_modules从stage区域删除。

```shell
git rm -r --cache node_modules
```

## Modify the Last Commit

针对最新的提交，如果我们发现有一些问题，想修改后重新提交，这样会产生新的commitid，为了不产生新的commitid，我们可以采用修补模式。

```shell
git add newfile
git commit --amend --no-edit
```

## Modify the Last Commit Message

针对最新的提交消息，我们想修改一下。

```shell
git commit --amend -m 'xxx'
or
git commit --amend
```

第二种方式在vim中进行提交消息的确认和修改

## Discarding all Changes in your working directory

* 如果本地对文件进行了修改，并且想放弃本地的修改

```shell
git restore .
```

* 针对某一个文件，想放弃本地的修改

```shell
git restore file.java
```

* 如果本地新增了文件，并且没有添加到stage区域，想快速删除这些文件

```shell
git clean -df
```

其中`-d`的作用是递归删除目录，`-f`的作用是强制删除，如果想删除.gitignore的配置的文件，需要添加`-x`

## Restore a file to an old version back in time

如果想针对某一个文件，恢复到历史的某一次提交

```shell
git restore -s hashid file.java
```

## Recover a deleted file

* 如果执行了`rm file.java`，并且没有提交到stage区域，想恢复这个被误删除的文件

```shell
git restore file.java
```

* 如果删除文件后，并且提交到stage区

```shell
git restore -S file.java
git restore file.java
```

其中`-S`参数是恢复stage区域，不加参数或者添加`-W`参数是恢复working tree区域

## Discard all changes in your local repo to exact state in remote

想让working tree，stage，repo都和remote repo的某次提交同步

```shell
git reset --hard origin/main
```

## Switch a commit to a different branch

如果你同时在两个分支工作，fea-a，fea-b，某一次提交本来应该在fea-b上，但是错误的提交在了fea-a上

```shell
git log
git checkout fea-b
git cherry-pick <commit-hash>
git checkout fea-a
git reset --hard HEAD~1
```

## Resurrect a deleted branch