;;; -*- coding: utf-8 -*-
;;; init.el --- Unified Emacs config -*- lexical-binding: t -*-

;; 起動高速化：システム設定をスキップし、GC閾値を一時的に上げる
(setq site-run-file nil)
(setq gc-cons-threshold (* 128 1024 1024))

;; 1. 共通設定の読み込み
(load (expand-file-name "init_common.el" user-emacs-directory))

;; 2. WSL環境判定
(defun running-in-wsl-p ()
  "WSL環境かどうかを判定します。"
  ;; WSL2 では WSLInterop があれば外部プロセスなしで判定できるため、起動時の uname 呼び出しを最後の保険にする。
  (or (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop")
      (and (executable-find "uname")
           (let ((case-fold-search t))
             (string-match "microsoft" (shell-command-to-string "uname -a"))))))

;; 3. 環境別設定のロード
(cond
 ((running-in-wsl-p)
  (message "Target Environment: WSL2")
  (load (expand-file-name "init_WSL2.el" user-emacs-directory))
  (load (expand-file-name "tex.el" user-emacs-directory)))
 ((eq system-type 'windows-nt)
  (load (expand-file-name "init_windows.el" user-emacs-directory)))
 (t
  (load (expand-file-name "init_linux.el" user-emacs-directory))
  (load (expand-file-name "tex.el" user-emacs-directory))))



;; 起動完了後にGC閾値を通常に戻す
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1024 1024))
            (message "Emacs 起動完了 (Time: %s)" (emacs-init-time))))
