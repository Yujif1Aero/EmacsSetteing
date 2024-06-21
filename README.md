# emacs setting
- write this into ~/.bashrc or shell something.Some PAHT in bash is used in eshell


```bash
## create emacs env file

perl -wle \
    'do { print qq/(setenv "$_" "$ENV{$_}")/ if exists $ENV{$_} } for @ARGV' \
    PATH > ~/.emacs.d/shellenv.el
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

for ubutsu
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

## GIT default editor

```bash
git config --global core.editor emacs
git config --global sequence.editor emacs
```

## GIT hub copilot
node.js >> version 18
```bash
sudo apt update
sudo apt install nodejs npm
git clone https://github.com/zerolfx/copilot.el.git
cd copilot.el
npm install
```

- ref : 
1. https://qiita.com/fnobi/items/8906c8e7759751d32b6b
1. https://github.com/xuchunyang/eshell-git-prompt
1. https://qiita.com/namn1125/items/5cd6a9cbbf17fb85c740
1. https://qiita.com/blue0513/items/acc962738c7f4da26656
1. https://qiita.com/kari_tech/items/4754fac39504dccfd7be
