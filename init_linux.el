(leaf xclip
;;  :ensure t

  :require t
  :straight t
  :config
  ;; xclip-mode を有効にする
  (xclip-mode 1))

(setq select-enable-clipboard t)
(setq select-enable-primary t)

(leaf eshell-git-prompt
  ;; :ensure t
  :require t
  :straight t
  :config
  (eshell-git-prompt-use-theme 'git-radar))


;; C-z で Emacs をサスペンドする
(global-set-key (kbd "C-z") 'suspend-emacs)

(require 'server)

(unless (server-running-p)
  (server-start))

(when (and (boundp 'server-socket-dir)
           server-socket-dir
           (boundp 'server-name)
           server-name)
  (setenv "EMACS_SOCKET_NAME"
          (expand-file-name server-name server-socket-dir)))
