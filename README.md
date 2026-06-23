# emacs setting
- write this into ~/.bashrc or shell something.Some PAHT in bash is used in eshell
```bash
## create emacs env file

perl -wle \
    'do { print qq/(setenv "$_" "$ENV{$_}")/ if exists $ENV{$_} } for @ARGV' \
    PATH > ~/.emacs.d/shellenv.el
```
Put this file in https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
to  /usr/local/etc/bash_completion.d for git in prompt.
```bash
mkdir /usr/local/etc/bash_completion.d
cd /usr/local/etc/bash_completion.d
sudo apt install hub

```

```bash
##move to project root
alias pjroot='cd $(git rev-parse --show-toplevel)'
```

# emacs install -> Please check emacs_installer.sh
```bash
#sudo add-apt-repository ppa:kelleyk/emacs
#sudo apt update
#sudo apt install emacs28-nativecomp
#sudo apt install emacs 
#sudo apt install fcitx-mozc
#sudo apt install mozc-server mozc-utils-gui mozc-data emacs-mozc
```



## add PATH (pip path)  今はpipの代わりにuvを使う予定なのでやる必要はないかな
for examples
```bash
export PATH=$PATH:/home/yuji_morgen1/.local/bin
```

## for compile_commands.json
```bash
pip install compiledb
compiledb make

```
or
```bash
make clean; bear -- make
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
sudo apt install ccls -> clang へ移行

```
project root directry として選択した履歴は`~/.emacs.d/lsp-session-v1` に残る。 もしかしたら、プロジェクトルートに`.ccls-root`を置く必要があるかも。基本的に`M-x lsp`したあとに `i`と入力すれば、OK
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
# 1) nvm をインストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# 2) bash 設定を読み直す
source ~/.bashrc

# 3) nvm が使えるか確認
command -v nvm

# 4) Node.js の LTS 版をインストール
nvm install --lts

# 5) その LTS を使う
nvm use --lts

# 6) 確認
node -v
npm -v
#nvm install 22
#npm install -g @github/copilot-language-server
npm -g --prefix ~/.emacs.d/.cache/copilot install @github/copilot-language-server
```

NOTE:
```
nvm install 22
npm install -g @github/copilot-language-server
これはする必要があります？

必要性を確認しています。ポイントは 「Copilot Language Server に Node 22 が本当に必要か」 と 「npm グローバル導入が必須か」 の2点です。

Thought for 1m 45s

結論だけ言うと、

Copilot を Emacs の copilot.el で使いたいなら、Node の更新は必要です

でも npm install -g @github/copilot-language-server は必須ではありません

理由はこうです。

copilot.el の README では、@github/copilot-language-server には Node.js 22+ が必要 と書かれていて、導入手順としては M-x copilot-install-server → M-x copilot-login が案内されています。つまり、Emacs 側の導入フローを使うなら、手動でグローバル npm install しなくてもよい ということです。

一方で、GitHub の copilot-language-server 公開リポジトリでは、npm install @github/copilot-language-server や npx @github/copilot-language-server --version の形が案内されていて、ローカル install や npx 実行も可能 です。なので、-g は「必須」ではなく「手動でグローバルに置きたいときの選択肢」 です。

それと、あなたの今の Node は v18.20.8 でしたが、Node 18 はすでに EOL です。現在は v24 が Active LTS、v22 が Maintenance LTS なので、今から入れ直すなら nvm install --lts のほうが自然です。copilot.el の条件である 22+ も満たします。

なので、あなたにはこの進め方をおすすめします。

nvm install --lts
nvm use --lts
node -v
npm -v

そのあと Emacs で:

M-x copilot-install-server

M-x copilot-login

これで十分です。npm install -g @github/copilot-language-server は、Emacs の自動導入がうまくいかないときだけ後から試せばOK です。

手動でやるなら、順番はこうです。

nvm install --lts
nvm use --lts
npm install -g @github/copilot-language-server

つまり、あなたの質問への答えはこうです。

nvm install 22
→ ほぼ必要。ただし 22固定より --lts がおすすめ

npm install -g @github/copilot-language-server
→ 必須ではない。copilot.el を使うならまず M-x copilot-install-server を試すのがよい

今すぐやるなら、まずはこれです。

nvm install --lts
nvm use --lts

その次に Emacs 側で M-x copilot-install-server を実行してください。
```
for windows user please refer to below URL
https://nodejs.org/ja/download

emacs action is
```
M-x copilot-reinstall-server
M-x copilot-login
```
## clang-format
```bash
sudo apt install clang-format
```
## helm-ag
```bash
sudo apt-get install silversearcher-ag
git clone https://github.com/emacsorphanage/helm-ag.git
```
M-x package-refresh-contents RET
M-x package-install RET helm-ag RET

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
cat >/tmp/git <<'GIT'
#!/bin/sh
GIT_WINDOWS="/mnt/c/Program Files/Git/cmd/git.exe(PATH to your git.exe in windows system)"
GIT_LINUX="/usr/bin/git"

case "$(pwd -P)" in
  /mnt/?/*) exec "$GIT_WINDOWS" "$@" | sed "s#\([A-E]\):#/mnt/\L\1#" ;;
  *) exec "$GIT_LINUX" "$@" ;;
esac
GIT
$sudo install /tmp/git /usr/local/bin
```

Put below .wslgconfig into C:\Users\<あなたのユーザー名>\.wslgconfig

```bash
[system-distro-env]
WESTON_RDP_DISABLE_HI_DPI_SCALING=true

```

## python
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
#source $HOME/.cargo/env
uv tool install black
```

## Other compiler
```
sudo apt update && sudo apt install -y texlive-full && sudo apt install -y libpng-dev zlib1g-dev libpoppler-glib-dev libpoppler-private-dev imagemagick
sudo apt install -y build-essential gfortran-13 libopenmpi-dev
sudo apt install bear
```

- ref :
1. https://qiita.com/fnobi/items/8906c8e7759751d32b6b
1. https://github.com/xuchunyang/eshell-git-prompt
1. https://qiita.com/namn1125/items/5cd6a9cbbf17fb85c740
1. https://qiita.com/blue0513/items/acc962738c7f4da26656
1. https://qiita.com/kari_tech/items/4754fac39504dccfd7be
1. https://blog.misosi.ru/2017/01/17/osc52e-el/

