;;; -*- coding: utf-8 -*-
;;; init_WSL2.el --- WSL2専用設定（高速化版）

;; 【修正】遅延の原因 である powershell.exe の呼び出しを削除しました。
;; 共通設定に統合された OSC 52 方式が、プロセスなしで爆速コピペを行います。

(leaf eshell-git-prompt
  :straight t
  :require t
  :config
  (when (fboundp 'eshell-git-prompt-use-theme)
    (eshell-git-prompt-use-theme 'powerline)))

(with-eval-after-load 'magit
  (setenv "GIT_EDITOR" "notepad.exe")
  (setq magit-git-global-arguments 
        (append magit-git-global-arguments '("-c" "core.editor=notepad.exe"))))

(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq frame-resize-pixelwise t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(when (display-graphic-p)
  (set-face-attribute 'default nil :height 140)
  (set-scroll-bar-mode nil)
  (set-fringe-mode 8))

(require 'server)
(unless (server-running-p) (server-start))

(message "init_WSL2.el has been loaded successfully.")
