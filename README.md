## emacssetting
- write this into ~/.bashrc or shell something.Some PAHT in bash is used in eshell

\## create emacs env file
perl -wle \
    'do { print qq/(setenv "$_" "$ENV{$_}")/ if exists $ENV{$_} } for @ARGV' \
    PATH > ~/.emacs.d/shellenv.el


# for ubutsu 
```bash
 $npm install -g pyright
 $sudo apt install clangd

```


- ref : 
1. https://qiita.com/fnobi/items/8906c8e7759751d32b6b
1. https://github.com/xuchunyang/eshell-git-prompt
1. https://qiita.com/namn1125/items/5cd6a9cbbf17fb85c740
