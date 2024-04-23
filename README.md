# emacssetting
write this into ~/.bashrc or shell something.Some PAHT in bash is used in eshell

\#\# create emacs env file
```
perl -wle \
    'do { print qq/(setenv "$_" "$ENV{$_}")/ if exists $ENV{$_} } for @ARGV' \
    PATH > ~/.emacs.d/shellenv.el
```


ref :  
https://qiita.com/fnobi/items/8906c8e7759751d32b6b
https://github.com/xuchunyang/eshell-git-prompt
https://qiita.com/namn1125/items/5cd6a9cbbf17fb85c740
