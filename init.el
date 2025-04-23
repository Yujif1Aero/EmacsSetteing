;;; init.el --- Unified Emacs config with OS-specific parts -*- lexical-binding: t -*-

;; 共通設定の読み込み
(load (expand-file-name "init_common.el" user-emacs-directory))

;; OS 判定関数（WSL用）
(defun running-in-wsl-p ()
  "WSL 上で Emacs が動作しているかを判定する"
  (and (eq system-type 'gnu/linux)
       (string-match "Microsoft" (shell-command-to-string "uname -r"))))

;; OSごとの設定読み込み
(cond
 ((running-in-wsl-p)
  (message "Loading WSL2-specific settings...")
  (load (expand-file-name "init_WSL2.el" user-emacs-directory)))

 ((eq system-type 'gnu/linux)
  (message "Loading NixOS-specific settings...")
  (load (expand-file-name "init_nixOS.el" user-emacs-directory))))
