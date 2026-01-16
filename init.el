;;; -*- coding: utf-8 -*-
;;; init.el --- Unified Emacs config with OS-specific parts -*- lexical-binding: t -*-

;; 1. 共通設定の読み込み
;; (init_common.el の中で straight.el や各パッケージの設定が行われます)
(load (expand-file-name "init_common.el" user-emacs-directory))

;; 2. OS判定関数の定義（より堅牢な判定に修正）
(defun running-in-wsl-p ()
  "WSL環境かどうかを判定します。"
  (or (let ((case-fold-search t)) ; 大文字小文字を区別しない
        (string-match "microsoft" (shell-command-to-string "uname -a")))
      (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop")))

;; 3. 環境に応じた設定ファイルのロード
(cond
 ;; WSL2 (Ubuntu on Windows)
 ((running-in-wsl-p)
  (message "Target Environment: WSL2")
  (load (expand-file-name "init_WSL2.el" user-emacs-directory)))

 ;; Windows (Native)
 ((eq system-type 'windows-nt)
  (message "Target Environment: Native Windows")
  (load (expand-file-name "init_windows.el" user-emacs-directory)))

 ;; 通常の Linux
 ((eq system-type 'gnu/linux)
  (message "Target Environment: Standard Linux")
  (load (expand-file-name "init_linux.el" user-emacs-directory))))

;; 4. 【重要】起動プロセスの最後にキーバインドを強制適用する
;; 他のパッケージが後から M-w を上書きするのを防ぐため、
;; emacs-startup-hook（全ロード完了後に実行されるフック）を使用します。
(add-hook 'emacs-startup-hook
          (lambda ()
            (if (fboundp 'smart-copy-to-windows-clipboard)
                (progn
                  (global-set-key (kbd "M-w") #'smart-copy-to-windows-clipboard)
                  (message "Final setup: M-w has been bound to smart-copy-to-windows-clipboard."))
              (message "Warning: smart-copy-to-windows-clipboard is not defined!"))))

;;; init.el ends here
