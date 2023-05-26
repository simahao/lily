# VIM

## vi/vim author(Bill/Bram)

* vi是vi编辑器的原始版本，vim是vi的增强版本，vim支持更多的特性，如 syntax highlighting，允许编辑超过8KB的文件等。
* vi只有命令行界面，而vim同时有命令行界面和图形用户界面。
* vim脚本更加强大，支持更高级的定制和扩展。

## vim配置

* ~/.vimrc|.viminfo|.vim|/etc/vimrc

  ```shell
  set background=dark
  set mouse-=a
  set nu
  syntax on
  set hlsearch
  set nocompatible
  filetype on
  set tabstop=4 "tab size=4
  set softtabstop=4 "backspace
  set shiftwidth=4 "indent
  set expandtab "tab is space
  set autoindent
  set incsearch
  set showmatch
  set cursorline
  colo gruvbox
  "set cursorcolumn
  "highlight CursorLine   cterm=NONE ctermbg=black ctermfg=NONE guibg=NONE guifg=NONE
  "highlight CursorColumn cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE

  let g:Lf_ShortcutF = '<c-p>'
  nnoremap <C-n> :NERDTree<CR>

  " set the runtime path to include Vundle and initialize
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
  " let Vundle manage Vundle, required
  Plugin 'VundleVim/Vundle.vim'
  Plugin 'elzr/vim-json'
  Plugin 'plasticboy/vim-markdown'
  Plugin 'tpope/vim-surround'
  Plugin 'flazz/vim-colorschemes'
  Plugin 'Yggdroot/LeaderF'
  Plugin 'preservim/nerdtree'
  " All of your Plugins must be added before the following line
  call vundle#end()            " required

  filetype plugin indent on    " required

  autocmd FileType java,shell,bash,cpp,html,cpp,vim,json setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
  autocmd FileType xml,yaml,yml setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

  ```

## 基本操作

* mode

  vim中包含三种模式，分别是插入模式，命令模式，块模式，进入三种模式的方式为：

  插入模式：命令模式下输入i/I

  命令模式：esc

  块模式：命令模式下输入V/^v

* save

  * w：保存
  * wq/ZZ：保存退出
  * q!：放弃修改

* move

  * hjkl：上下左右一个光标位置
  * e/E(w/W) b/B：调转到单词结尾和开头

    ```shell
    how are you?
    core.tar.gz
    ```

  * f/F：forword，从前向后查找一个字符，并jump到对应的字符，之后输入`;`可以重复执行该命令。F代表从后向前
  * t/T：till，从前向后，直到某个字符，光标停止在这个字符之前，之后输入`;`可以重复执行该命令。T代表从后向前。
  * 0/^：hard bol/soft bol，主要区别在于行首是否有空格和tab，如果有tab或者空格，软行首会定位在首个单词的首字符。
  * $：行尾
  * gg：文本首行
  * G：文本末行
  * xG：x代表数字，定位具体行数
  * x%：x代表具体数字，定位百分比
  * ()：句子开头结尾
  * {}：段落开头结尾

* text object

  * aw：一个单词
  * ap：一段
  * as：一句话
  * ab：一块（包含在小括号内）

* edit

  * i/I：光标前插入，当前行行首插入
  * 8i= esc：插入8个=
  * a/A：光标后增加，当前行行尾增加
  * J：将下一行连接到当前行
  * o/O：当前行下面增加一行，当前行上面增加一行
  * d[n]w：删除一个（n个）单词
  * dti：删除字符直到i
  * dfi：删除字符到i，包含i
  * d0：删除到行首
  * D/d$：删除到行尾
  * dG：当前行到文档末尾全部删除
  * dgg：当前行到文档开头全部删除
  * [n]dd：删除一行（n行）
  * r：进入替换模式
  * s/S：删除光标所在字符，删除光标所在行
  * C：删除光标位置到行尾

* copy/cut/paste

  * yy/Y：复制一行
  * [n]yy：复制n行
  * y[ft]x：复制到x字符（包含x），复制到x字符（不包含x）
  * y[FT]x：从后向前复制
  * yw：复制一个单词
  * y0：复制光标位置到行首
  * y$：复制光标位置到行尾
  * ygg：复制当前行到文档开始
  * yG：复制当前行到文档结尾
  * yaw：复制一个单词
  * yas：复制一句话
  * p/P：在光标之后粘贴，在光标之前粘贴
  * 剪切：将y命令换成x，如xw，剪切一个单词，xG，当前行到文档末尾剪切掉
  * :set paste：改命令可以实现格式化粘贴

* search/replace

  * /：/keyword，在当前位置后面查找keyword
  * ?：?keyword，在当前位置之前查找keyword
  * n/N：向后、向前继续查找
  * *：查找单词
  * %：跳转到匹配
  * #：反向查找单词
  * :.s/old/new：用new替换当前行第一个old
  * :.s/old/new/g：用new替换当前行所有的old
  * :.s/old/new/gi：用new替换当前行所有的old，忽略大小写
  * m,ns/old/new/g：从m行到n行，用new替换所有old
  * :%s/old/new/g：全文范围，用new替换old
  * :%s/^ xyz/dd：删除空格开头，后面是xyz的所有行
  * :%s/^/abc/g：所有行首添加abc
  * :%s/$/abc/g：所有行尾添加abc

* indent

  * shift+>：向右缩进
  * shift+<：向左缩进
  * .：重复执行

* jump

  * ^o：如果从A文件跳转到B文件， ^o可以实现从B文件返回A文件，也可以是文件内跳转，例如mark功能
  * ^i：和 ^o对应，互相切换

* mark

  * m[a-z]：标记光标所在位置
  * :marks：显示所有标记
  * ‘[a-z]：跳转到标记处所在行
  * `[a-z]：精确跳转到标记位置
  * m[A-Z]：全局有效，实现不同文件跳转

* undo/redo/repeat

  * u：undo一次操作
  * 3u：undo三次操作
  * U：放弃当前行的修改
  * c^r：redo一次
  * .：重复上一次命令
  * ;：重复[tTfF]
  * ,：反向[tTfF]

* file type

  * :set ff：显示文件格式
  * :set ff=unix

* register

  * "ayw：复制一个单词，放到寄存器a中
  * "ap：将寄存器a中的值粘贴到当前光标之后

* lower/upper

  * guu：当前行小写
  * gUU：当前行大写
  * ~：一个字符一个字符改变大小写
  * g~~：当前行改变大小写
  * gU$：从光标位置到行尾大写
  * Vu：当前行小写
  * VU：当前行大写
  * ggguG：gg开头，G结尾，gu小写，从开头到结尾全部小写
  * gggUG：gg开头，G结尾，gu小写，从开头到结尾全部大写
  * 3guu：3行小写

* interacting with OS

  * :!pwd

* split

  * :split：上下切分窗口
  * :vert split：左右切分窗口
  * :res：上下窗口resize
  * :vert res：左右窗口resize
  * c^w[hjkl]：窗口间移动光标
  * c^wc：关闭当前窗口

* macro

  * q[a-z]：定义宏
  * [n]@[a-z]：播放宏一次或者n次

* help

  * :h gg：查看gg命令
  * :h v_u：在可是模式下，使用u命令
  * :h ctrl-v：
  * :h magic：文本
  * :h /[：正则表达式
