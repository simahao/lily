# **cloc 使用**

业务产品部（zhanghao）

| 版本 | 备注                                                         |    日期    |
| :--: | ------------------------------------------------------------ | :--------: |
| 1.0  | 初始版本，包括安装、基本命令格式、常用参数、使用场景         | 2024/11/25 |
| 1.1  | 场景描述中，增加<br />1. 支持PL/SQL的bdy后缀的统计方案       | 2024/11/26 |
| 1.2  | 在场景描述中，增加<br />1. git合并其他人代码后，删除本地分支，如何统计的方案<br />2. --git场景说明<br />3. 目录对比、压缩文件对比的说明<br />4. 超时处理<br />5. git管理的文件，文件名是utf-8格式<br />6. cloc的限制说明 | 2024/11/27 |
| 1.3  | 在场景描述中，增加<br />1. 针对2.03版本的说明<br />2. 添加正则匹配的说明<br />3. 添加哪些文件会被忽略 | 2024/12/11 |



[TOC]

## 安装

windows系统下，将cloc去掉版本标识符后，放到`C:\Windows\System32`下，并且要在cmd模式下运行（不要在powershell和git bash下运行）

推荐在WSL或者linux下运行，避免一些路径问题，同时可以增加并行度参数，加快运行速度

## 基本命令格式

```bash
Usage: cloc.exe [options] <file(s)/dir(s)/git hash(es)> | <set 1> <set 2> | <report files>
```

## 常用参数

### Processing Options

```bash
    --diff <set1> <set2>     Compute differences in code and comments between
                             source file(s) of <set1> and <set2>.  The inputs
                             may be any mix of files, directories, archives,
                             or git commit hashes.  Use --diff-alignment to
                             generate a list showing which file pairs where
                             compared.  When comparing git branches, only files
                             which have changed in either commit are compared.
                             See also --git, --count-and-diff, --diff-alignment,
                             --diff-list-file, --diff-timeout, --ignore-case,
                             --ignore-whitespace.
    --git                    Forces the inputs to be interpreted as git targets
                             (commit hashes, branch names, et cetera) if these
                             are not first identified as file or directory
                             names.  This option overrides the --vcs=git logic
                             if this is given; in other words, --git gets its
                             list of files to work on directly from git using
                             the hash or branch name rather than from
                             'git ls-files'.  This option can be used with
                             --diff to perform line count diffs between git
                             commits, or between a git commit and a file,
                             directory, or archive.  Use -v/--verbose to see
                             the git system commands cloc issues.     
    --git-diff-rel           Same as --git --diff, or just --diff if the inputs
                             are recognized as git targets.  Only files which
                             have changed in either commit are compared. 
    --by-file                Report results for every source file encountered.
                             See also --fmt under 'Output Options'.
    --by-file-by-lang        Report results for every source file encountered
                             in addition to reporting by language.
                   
```

说明：

1. `--git`参数避免后面的commitid误识别为文件或者目录，如果不添加`--git`运行正常，可以忽视它
2. `--diff`是我们主要使用的参数，维护项目主要是修改类，所以要进行前后版本的比对，统计代码行数
3. `--git-diff-rel`如果`cloc`认为输入是git targets，该参数效果同`--diff`

### Filter Options

```bash
   --exclude-dir=<D1>[,D2,]  Exclude the given comma separated directories
                             D1, D2, D3, et cetera, from being scanned.  For
                             example  --exclude-dir=.cache,test  will skip
                             all files and subdirectories that have /.cache/
                             or /test/ as their parent directory.
                             Directories named .bzr, .cvs, .hg, .git, .svn,
                             and .snapshot are always excluded.
                             This option only works with individual directory
                             names so including file path separators is not
                             allowed.  Use --fullpath and --not-match-d=<regex>
                             to supply a regex matching multiple subdirectories.
   --exclude-ext=<ext1>[,<ext2>[...]]
                             Do not count files having the given file name
                             extensions.
   --include-ext=<ext1>[,ext2[...]]
                             Count only languages having the given comma
                             separated file extensions.  Use --show-ext to
                             see the recognized extensions.
   --include-lang=<L1>[,L2[...]]
                             Count only the given comma separated, case-
                             insensitive languages L1, L2, L3, et cetera.  Use
                             --show-lang to see the list of recognized languages.
   --fullpath                Modifies the behavior of --match-f, --not-match-f,
                             and --not-match-d to include the file's path--
                             relative to the directory from which cloc is
                             invoked--in the regex, not just the file's basename.
                             (This does not expand each filename to include its
                             fully qualified absolute path; instead, it uses as
                             much of the path as is passed in to cloc.)                           
   --match-d=<regex>         Only count files in directories matching the Perl
                             regex.  For example
                               --match-d='/(src|include)/'
                             only counts files in directories containing
                             /src/ or /include/.  Unlike --not-match-d,
                             --match-f, and --not-match-f, --match-d always
                             anchors the regex to the directory from which
                             cloc is invoked.
   --not-match-d=<regex>     Count all files except those in directories
                             matching the Perl regex.  Only the trailing
                             directory name is compared, for example, when
                             counting in /usr/local/lib, only 'lib' is
                             compared to the regex.
                             Add --fullpath to compare parent directories, beginning
                             from the directory where cloc is invoked, to the regex.
                             Do not include file path separators at the beginning
                             or end of the regex. This option may be repeated.
   --match-f=<regex>         Only count files whose basenames match the Perl
                             regex.  For example
                               --match-f='^[Ww]idget'
                             only counts files that start with Widget or widget.
                             Add --fullpath to include parent directories
                             in the regex instead of just the basename.
   --not-match-f=<regex>     Count all files except those whose basenames
                             match the Perl regex.  Add --fullpath to include
                             parent directories in the regex instead of just
                             the basename. This option may be repeated.                             
```

说明：

1. `--exclude-dir`：通常是去掉一些当前目录下不需要统计的目录，如.git/.svn（这些默认排除掉了），这个选项和git中的`.gitignore`的作用有点类似，但是需要注意，他不能排除掉子目录，也就是`dir1/subdir`这样的写法是错误的，如果有这样的需求，需要参考`--full-path --not-match-d`选项来实现
2. `--not-match-d`、`--match-f`、`--not-match-f`这三个参数都是锚定**（anchors）**当前目录或者当前文件，也就是通常我们所说的basename，如果我们需要上级目录，需要结合`--full-path`参数，这个特性和`--match-d`的默认行为不同，`--match-d`是基于perl的正则进行匹配，匹配上了，就纳入统计范围

### Output Options

```bash
   --csv                     Write the results as comma separated values.
   --csv-delimiter=<C>       Use the character <C> as the delimiter for comma
   --md                      Write the results as Markdown-formatted text.
   --out=<file>              Synonym for --report-file=<file>.
```

说明：

​	如果考虑统计方便，可以结果输出到csv文件，默认为comma为分隔符

## 使用场景

1. 2.02版本和2.03版本的说明

   2.02版本是2024/8/3日发布的，这个版本存在已知的2个问题

   - 不能识别PL/SQL中的bdy文件（2.02版本的处理方案参照后续场景的说明）
   - 针对bdy文件和vue文件，如果同一行包含代码和注释，错误的按照注释进行统计

   2.03版本解决了这些问题，建议使用2.03版本，由于windows的可执行文件要跟随发布才能提供出来，因此建议使用linux下的cloc，仓库会实时更新，cloc位于仓库的根目录下 [AlDanial/cloc](https://github.com/AlDanial/cloc)

   

2. 哪些文件会被忽略

   如果文件的md5值一致，cloc会保留一个文件进行统计，可以关注cloc的统计结果，下面的例子中，cloc统计的2个txt文件，md5相同，cloc认为是一个文件，输出结果也只有一个文件，可以通过`--by-file`查看统计的明细

   ```bash
   ❯ cloc --by-file .
          2 text files.
          1 unique file.
          2 files ignored.
   
   ```

   

3. 统计过程提示超时错误👿

   ```bash
   error: exceeded timeout
   ```

   解决方案，其中`--diff-timeout`超时参数负责处理对比算法的超时，`--timeout`参数的超时负责处理cloc的filter stage的超时

   ```bash
   --diff-timeout <N>        Ignore files which take more than <N> seconds
                             to process.  Default is 10 seconds.  Setting <N>
                             to 0 allows unlimited time.  (Large files with many
                             repeated lines can cause Algorithm::Diff::sdiff()
                             to take hours.) See also --timeout.
   --timeout <N>             Ignore files which take more than <N> seconds
                             to process at any of the language's filter stages.
                             The default maximum number of seconds spent on a
                             filter stage is the number of lines in the file
                             divided by one thousand.  Setting <N> to 0 allows
                             unlimited time.  See also --diff-timeout.                            
   ```

   

4. git管理，文件名称为中文utf-8格式，导致cloc运行失败💣

   ```bash
   fatal: pathspec '\344\244\223\475.sql' did not match any path
   ```

   解决方案

   ```bash
   git config --global core.quotepath off
   ```

   如果依然出现问题，可以选择将两个提交点对应的结构保存在gz文件中

   ```bash
   git archive -o 1.tar.gz commitid1
   git archive -o 2.tar.gz commitid2 
   cloc --diff 1.tar.gz 2.tar.gz
   ```

   

5. cloc的输入如果是git target，可能会提示错误😓

   ```bash
   cloc --diff 1.3.0 1.4.0
   
   2 errors:
   Unable to read: 1.4.0
   Unable to read: 1.3.0
   Nothing to count.
   ```

   对于cloc来说，混合输入，特别是输入的信息和目录名称、文件名称类似，cloc不能很好好的分辨，可以通过添加`--git`强制cloc将输入认为是git target。

   ```bash
   cloc --diff --git commit1 commit2
   #或者
   cloc --git-diff-rel commit1 commit2
   ```

6. 对比目录、压缩文件🚛

   ```bash
   # 如果是全新建立的工程，不需要对比，直接统计目录下的代码即可
   cloc dir
   # 如果通过两个目录进行代码比对
   cloc --diff dir1 dir2
   # 对比两个压缩包，前提是系统安装了对应的解压软件，如果cloc找不到，可以强制给出解压软件路径
   cloc --diff xx.tar.gz  yy.tar.gz
   # 
   cloc --diff --extract-with="\"c:\Program Files\WinZip\WinZip32.exe\" -e -o >FILE< ." x.zip y.zip
   ```

   

7. **排除掉cloc运行目录下的某一个目录或者多个目录**📇

   ```bash
   |-- .git
   |-- .cache
   |-- module1
   |   `-- src
   |-- module2
   |   `-- src
   |-- module3
   |   `-- src
   `-- tmp
   
   ```

   ```bash
   cloc --diff --exclude-dir=.cache,tmp commit1 commit2
   ```

   `--exclude-dir`不能排除多级目录，如`tmp/subdir`，这种需求需要通过`--fullpath --not-match-d`实现

8. **排除测试代码**🍭

   ```bash
   cloc --diff --not-match-d=test commit1 commit2
   cloc --diff --not-match-f=".*Test\.java" commit1 commit2
   cloc --diff --full-path --not-match-f="test/.*/.*Test\.java" commit1 commit2
   ```

9. **统计测试代码**🧁

   ```bash
   cloc --diff --match-d=".*/test" commit1 commit2
   ```

   为什么不能用这个命令`cloc --diff --match-d="test" commit1 commit2`统计测试代码，我们假设目录结构如下

   ```cmd
   src
   |-test/com/dce/xxxTest.java
   |-test/com/dce/yyyTest.java
   |-a-test/a.java
   ```

   由于`a-test`符合`--match-d`的正则匹配，所以，`a-test/a.java`也会被统计，但是针对测试代码，我们并不想统计`a-test/a.java`这个文件，因此建议通过相对长的路径来统计测试代码更稳妥。另外，如果想加快统计的效率和速度，因此也可以强制指定语言，或者指定扩展名的方式，比如

   ```bash
   cloc --diff --include-lang=java --match-d="test" commit1 commit2
   cloc --diff --include-ext=java --match-d="test" commit1 commit2
   ```

10. 关于匹配目录的正则表达式

   * 多目录匹配

     ```bash
     # 不统计当前目录下，包含test、abc字样的目录下的代码
     # 如果目录是atest，test1，abcd，都会排除
     cloc --diff --git --not-match-d="(test|abc)" commit1 commit2
     cloc --diff --git --not-match_d="test" --not--match-d="abc" commit1 commit2
     cloc --diff --git --fullpath --not-match-d=".*/test" commit1 commit2
     ```

     如果我只想匹配test目录

     ```bash
     cloc --diff --git --fullpath --not-match-d=".*/test$" commit1 commit2
     ```

     再给一个复杂的例子

     如果全路径中，我们想排除node_modules、target、txa、txb、txc目录，不匹配csv、md、json文件，将结果输出到report.txt中

     ```bash
     cloc --fullpath --not-match-d='/(node_modules|target|tx[abc])/' --not-match-f='.*\.(csv|md|json)' --report-file=report.txt
     ```

     由于正则匹配需要保证表达式正确，因此**特别建议**将统计的明细进行打印确认，我们可以利用两个参数，分别是`--by-file`，`--by-file-by-lang`，这两个参数会打印所有的统计文件明细

     ```bash
     cloc --diff --git --by-file --not-match_d="test" commit1 commit2
     cloc --diff --git --by-file-by-lang --not-match_d="test" commit1 commit2
     ```

     

11. **如何统计PL/SQL中的bdy文件**🛠️

    cloc-2.02之前的版本默认不能支持bdy后缀，同时统计bdy文件的代码时，如果一行当中既有代码也有注释，cloc-2.02版本按照注释统计，因此，可以使用2.03版本，如果要使用2.02版本，可以使用`--force-lang`参数处理

    **方案1**

    ```bash
    cloc --force-lang='sql,bdy' a.bdy
    
           1 text file.
           1 unique file.
           0 files ignored.
    
    github.com/AlDanial/cloc v 2.02  T=0.02 s (45.0 files/s, 374572.6 lines/s)
    --------------------------------------------------------------------------------------
    Language                            files          blank        comment           code
    --------------------------------------------------------------------------------------
    Oracle PL/SQL Body Files                1            371           2414           5541
    --------------------------------------------------------------------------------------
    ```

    **方案2**是通过脚本先更新文件后缀，然后用默认的```bod```后缀进行统计

    在需要统计代码的目录下，通过cmd方式执行如下代码

    ```cmd
    for /r %i in (*.bdy) do ren "%i" "%~ni.bod"
    ```

    ```bash
    cloc dir1
         101 text files.
         100 unique files.
           5 files ignored.
    
    github.com/AlDanial/cloc v 2.02  T=0.46 s (217.3 files/s, 643646.4 lines/s)
    -------------------------------------------------------------------------------
    Language                     files          blank        comment           code
    -------------------------------------------------------------------------------
    Oracle PL/SQL                   99          22324         102973         170583
    SQL                              1            115             14            206
    -------------------------------------------------------------------------------
    SUM:                           100          22439         102987         170789
    -------------------------------------------------------------------------------
    ```

    

12. **针对历史项目，已经合并入master，且本地分支删除，如何统计？**🏋️‍♂️

   针对历史项目（已经上线），本项目的代码，在合并进入master前，通常会合并其他项目或者生产变更代码之后再进入master，项目上线后，将本地分支删除（包括远程的该分支）。这种场景下，如果要统计代码，如何处理？总体来看，可以参考一下思路

   > [!IMPORTANT]
   >
   > 我们可以认为，我们的项目合并了其他项目或者变更的代码，是基于这些被合并的项目或者变更在我的项目之前上线，也就是他们应该早于我的项目合并进入master，那么我的项目合并了这些项目或者变更，如果在差分代码的时候，这些项目和变更已经合并进入master，那么我们可以认为，项目分支合并了若干其他项目或者变更的代码（本项目），在master上找到合并进入我们项目最后一个项目（变更）的提交点，他们之间做差分，就是本项目单独引入的代码修改。以上是基于我们在合并其他项目或者变更的时候选用了merge命令，如果我们在合并其他项目或者变更的时候一直选用rebase，那么可以认为和master分支对比即可。

   这里面先举一个简单的例子

   1. master提交2次

   2. 建立feat分支，提交一次

   3. 紧急变更，建立hotfix分支，修改后的代码并合并到master

   4. feat准备合并到master，先merge master处理冲突，然后通过Fast-Forward合并到master

      以下log tree代表以上4个步骤之后产生的结果

      ```yaml
      *   dc2c373 - (HEAD -> master, feat) feat: merge master 
      |\
      | *   f0bbe91 - master: merge hotfix 
      | |\
      | | * ef58b9f - (hotfix) hotfix: 1 
      | * | 485af69 - master: 3 
      | |/
      * / f6b4fcb - feat: 1 
      |/
      * 50ee476 - master: 2 
      * 03652fb - master: 1 
      ```

      我们可以运行`git reflog`查看细节信息

      ```yaml
      git reflog
      
      dc2c373 (HEAD -> master) HEAD@{0}: merge feat: Fast-forward
      f0bbe91 HEAD@{1}: checkout: moving from feat to master
      dc2c373 (HEAD -> master) HEAD@{2}: commit (merge): feat: merge master
      f6b4fcb HEAD@{3}: checkout: moving from master to feat
      f0bbe91 HEAD@{4}: commit (merge): master: merge hotfix
      485af69 HEAD@{5}: commit: master: 3
      50ee476 HEAD@{6}: checkout: moving from hotfix to master
      ef58b9f (hotfix) HEAD@{7}: commit: hotfix: 1
      50ee476 HEAD@{8}: checkout: moving from master to hotfix
      50ee476 HEAD@{9}: checkout: moving from feat to master
      f6b4fcb HEAD@{10}: commit: feat: 1
      50ee476 HEAD@{11}: checkout: moving from master to feat
      50ee476 HEAD@{12}: commit: master: 2
      03652fb HEAD@{13}: commit (initial): master: 1
      ```

      由于feat进入master之前，已经将master分支的提交(485af69 master: 3)和hotfix分支的提交（ef58b9f - (hotfix) hotfix: 1）合并进入feat，因此我们认为**`dc2c373`**这次提交包含了`485af69`和`ef58b9f`，而**`f0bbe91`**这次提交就是feat进入master之前的状态，因此我们可以通过这两次commitid进行代码统计

      ```bash
      cloc --diff --git f0bbe91 dc2c373
      ```

   针对更复杂的案例，我们具体演示如何处理，这个案例是在上面的基础上，遇到了一个问题，项目上线时，合并了其他变更一同上线，这些被合并的变更并没有进入master分支

   1. 在master分支中找到本项目上线时的PR，通过`git checkout -b my-project commitid`生成项目对应的分支，这里面的commitid如何找到呢？因为我们上线前，会通过PR合并进入master，所以可以通过提交信息找到

      ```yaml
      Merge pull request '【23年清算7.0优化项目二阶段】【1114变更】【1260变更】入库' from master-perf-p2 into master  c611efa4
      ```

      my-project这个新建立的分支，就是基于项目+2个变更合并到master之后的状态，建立这个新的分支实际是为了方便查找后面的commitid，对于cloc统计来说，只关心commitid，也就是如果能快速找到2个commitid，不建立这个分支也可以。

   2. 切换到my-project分支上`git switch my-project`，找到最近一个`Merge pull request ... from yyy into master`的提交，也就是我的项目上线前最后一个项目或者变更上线的状态，寻找这个提交点和第一步类似，参考一下commit信息

      ```yaml
      Merge pull request 'refactor: update commitconfig' from master-pipe-zgf into master 882b0aee
      ```

   3. 因为这个项目上线的时候，合并了变更（这些变更并没有进入master分支），所以统计代码的时候，需要将第一步的结果排除掉这些合并上线的变更

      ```yaml
      * Merge remote-tracking branch 'origin/master-change-1114' into master-perf-p2  acbc4e
      |
      * Merge remote-tracking branch 'origin/master-change-1260' into master-perf-p2  6e3a66
      |
      * fix: 去掉合版时产生的非法字符                                                     5564e8
      |
      * Merge branch 'master' into master-perf-p2                                     fbc903
      ```

      通过这个提交日志，我们可以看到最上面合并远程分支就是合并变更上线的过程，下面的`5564e8`去除非法字符就是本项目的开发最终状态（合并了其他进入master的项目和变更）

      ```bash
      cloc --git --diff 882b0 5564e8
      ```

      

## cloc的限制

> [!CAUTION]
>
> 注意事项

1. 一行当中既有代码也有注释，按照代码统计，因此建议注释不要和代码放到同一行

   ```plsql
   select *   --检索所有列
   from table
   ```

   ```java
   private String clientName; #客户姓名
   ```

   2.02版本，针对bdy和vue后缀文件有缺陷，因此要使用2.03版本

2. 内嵌的语言不会被统计，比如说HTML中包含了JavaScript，那么JavaScript统一按照HTML统计

3. windows上，文件名不能超过255

4. 对于内嵌的注释，cloc不能很好的统计出结果

   ```java
   /* /* */ */
   ```

   

