(leaf xclip
  :straight t
  :config
  ;; xclip-mode を有効にする
  (xclip-mode 1))

(setq select-enable-clipboard t)
(setq select-enable-primary t)

(leaf eshell-git-prompt
  :straight t
  :config
  (eshell-git-prompt-use-theme 'git-radar))


;; C-z で Emacs をサスペンドする
(global-set-key (kbd "C-z") 'suspend-emacs)

