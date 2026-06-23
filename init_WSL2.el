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

;; (setq select-enable-clipboard t)
;; (setq select-enable-primary t)
(setq select-enable-clipboard nil)
(setq select-enable-primary nil)
(setq interprogram-paste-function nil)
(setq frame-resize-pixelwise t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(when (display-graphic-p)
  (set-face-attribute 'default nil :height 140)
  (set-scroll-bar-mode nil)
  (set-fringe-mode 8))

(require 'server)
(unless (server-running-p) (server-start))
;; --- クリップボード連携 (tmux 対応版 OSC 52) ---
(defun my/copy-to-clipboard (text)
  "OSC 52 を使い、tmux 越しでも Windows へコピーする。日本語対応。"
  (condition-case nil
      (let* ((encoded-text (encode-coding-string text 'utf-8))
             (b64-text (base64-encode-string encoded-text t))
             (osc52-string (if (getenv "TMUX")
                               (format "\ePtmux;\e\e]52;c;%s\a\e\\" b64-text)
                             (format "\e]52;c;%s\a" b64-text))))
        (send-string-to-terminal osc52-string))
    (error nil)))

;; ==========================================
;; tmux/ターミナル環境での自動クリップボード同期を強制遮断
;; ==========================================
(unless (display-graphic-p)
  (setq xterm-select-enable-clipboard nil)
  (setq interprogram-paste-function nil)
  (setq interprogram-cut-function nil))

;; 選択範囲をWindowsのクリップボードへ明示的に送るショートカット (例: C-c c)
(defun my/copy-region-to-clipboard (beg end)
  "選択範囲をOSC 52経由でWindowsのクリップボードにコピーする。"
  (interactive "r")
  (if (use-region-p)
      (let ((text (buffer-substring-no-properties beg end)))
        (my/copy-to-clipboard text)
        (message "クリップボードにコピーしました！"))
    (message "範囲が選択されていません。")))

(global-set-key (kbd "C-c c") #'my/copy-region-to-clipboard)
(message "init_WSL2.el has been loaded successfully.")
