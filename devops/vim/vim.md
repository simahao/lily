# VIM

## vi/vim author(Bill/Bram)

* vi是vi编辑器的原始版本，vim是vi的增强版本，vim支持更多的特性，如 syntax highlighting，允许编辑超过8KB的文件等。
*  vi只有命令行界面，而vim同时有命令行界面和图形用户界面。
* vim脚本更加强大，支持更高级的定制和扩展。

## vim配置

* ~/.vimrc|.viminfo|.vim|/etc/vimrc

  ```shell
  set background=dark                                                                                        set mouse-=a
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
  
  " set the runtime path to include Vundle and initialize
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
  
  " let Vundle manage Vundle, required
  Plugin 'VundleVim/Vundle.vim'
  
  Plugin 'tpope/vim-fugitive'
  Plugin 'git://git.wincent.com/command-t.git'
  Plugin 'elzr/vim-json'
  Plugin 'kien/ctrlp.vim'
  Plugin 'plasticboy/vim-markdown'
  Plugin 'tpope/vim-surround'
  Plugin 'vim-scripts/a.vim'
  Plugin 'flazz/vim-colorschemes'
  
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

    - w：保存
    - wq/ZZ：保存退出
    - q!：放弃修改

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

  * edit

  * search/replace

  * tab

  * mark

  * undo/redo/repeat

  * register

  * regex

  * lower/upper

  * interactive with OS

  * split

    