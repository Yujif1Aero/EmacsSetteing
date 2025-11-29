# emacs setting
- write this into ~/.bashrc or shell something.Some PAHT in bash is used in eshell
# emacs install
```bash
sudo apt install emacs28-nativecomp
sudo apt install fcitx-mozc
sudo apt install mozc-server mozc-utils-gui mozc-data emacs-mozc
```

```bash
## create emacs env file


perl -wle \
    'do { print qq/(setenv "$_" "$ENV{$_}")/ if exists $ENV{$_} } for @ARGV' \
    PATH > ~/.emacs.d/shellenv.el
```
```bash
##move to project root
alias pjroot='cd $(git rev-parse --show-toplevel)'
```


## add PATH (pip path)
for examples
```bash
export PATH=$PATH:/home/yuji_morgen1/.local/bin
```

## for compile_commands.json
```bash
pip install compiledb
compiledb make

```

## for installing key

1. Emacsを開き、M-x package-install-file を実行します。
1. プロンプトが表示されたら、ダウンロードした gnu-elpa-keyring-update の .tar ファイルへの完全なパスを入力します。
1. インストールが完了したら、Emacsを再起動してください。

## eglot(今は使っていない)

```
M-x eglot
if you do not have `compile_commands.json` , for example put clangd in C++/C. CHECK sever list in refernce git URL. 
ref : https://github.com/joaotavora/eglot
```

## additional instaling for LSP ( もしかしたら，メタプログラミングに不向き？)


 1. python code
```bash
 npm install -g pyright

```
 1. c/c++ code
```bash
 sudo apt install clangd
```

## ccls(clangdよりも重い) けど優秀

```bash
sudo apt install ccls

```
project root directry として選択した履歴は`~/.emacs.d/lsp-session-v1` に残る。 もしかしたら、プロジェクトルートに`.ccls-root`　を置く必要があるかも。基本的に`M-x lsp`したあとに `i`と入力すれば、OK 
`_.dir-locals.el`を参考にして project root directryに`.dir-locals.el`として置くこと。注意 ！！！`.dir_locals.el`名前はこれではない。バー `-`にしてね。
project root directry に`.ccls`を置こう。中身は一行  `%compile_commands.json`のみでOK
## GIT default editor

```bash
git config --global core.editor emacs
git config --global sequence.editor emacs
```



## os52.el
I will use `os52` to share clip bord between local and sever.Or I set `(el-get-bundle gist:49eabc1978fe3d6dedb3ca5674a16ece:osc52e)` in this `init.el`

```bash
 wget https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc/osc52.el -O ~/.emacs.d/osc52.el

```
貼り付けに関してはsshをしていても cntl+shift+vでできるように元に戻った（謎）


## GIT hub copilot
node.js >> version 18
```bash
sudo apt update
sudo apt install nodejs npm
~~git clone https://github.com/zerolfx/copilot.el.git~~
~~cd copilot.el~~
~~npm install~~
npm install -g @github/copilot-language-server
```

## clang-format
```bash
sudo apt install clang-format
```
## helm-ag
```bash
sudo apt-get install silversearcher-ag
```
M-x helm-ag-edit を使用して通常のバッファに変換する helm-ag の検索結果を helm-ag-edit で編集可能なバッファに展開することで、通常の Emacs の C-s 検索機能を利用できるようにします。

手順：
helm-ag の検索結果が表示されている状態で C-c C-e（または M-x helm-ag-edit）を実行します。
検索結果が通常のバッファとして表示されるので、その状態で C-s を使用して文字列を検索します。

helm-do-agでファイル内文字列の検索をしないファイルはやディレクトは`.agignore`に書いてプロジェクトルートに置く。

## ollama
```bash
ollama serve
```
## Whitespace (ホワイトスペース)
M-x whitespace-mode
M-x global-whitespace-mode

## Undo-Tree (アンドゥツリー)
M-x undo-tree-visualize

## Kill Ring
M-x helm-show-kill-ring
C-x c M-y

## wsl environment setting
git infomation show slow when workspace is in not wsl system but in windows system.
Adapt below commands:
```bash
$cat >/tmp/git <<'GIT'#!/bin/sh GIT_WINDOWS="/mnt/c/Program Files/Git/cmd/git.exe"
 GIT_LINUX="/usr/bin/git"
case "$(pwd -P)" in
  /mnt/?/*) exec "$GIT_WINDOWS" "$@" | sed "s#\([A-E]\):#/mnt/\L\1#" ;;
  *) exec "$GIT_LINUX" "$@" ;;
 esacGIT
$sudo install /tmp/git /usr/local/bin
```
- ref :
1. https://qiita.com/fnobi/items/8906c8e7759751d32b6b
1. https://github.com/xuchunyang/eshell-git-prompt
1. https://qiita.com/namn1125/items/5cd6a9cbbf17fb85c740
1. https://qiita.com/blue0513/items/acc962738c7f4da26656
1. https://qiita.com/kari_tech/items/4754fac39504dccfd7be
1. https://blog.misosi.ru/2017/01/17/osc52e-el/
