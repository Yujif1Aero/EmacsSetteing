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
  (set-fringe-mode 8)
  ;; --- 日本語フォント設定 (X/WSLg GUI 用) ---
  ;; インストール済みのものを上から順に探して割り当てる。
  (let ((jp-font (seq-find (lambda (f) (member f (font-family-list)))
                           '("Noto Sans CJK JP" "Noto Sans JP"
                             "BIZ UDGothic" "Yu Gothic" "Meiryo"))))
    (when jp-font
      (dolist (charset '(japanese-jisx0208 japanese-jisx0212
                         katakana-jisx0201 kana han cjk-misc symbol))
        (set-fontset-font t charset (font-spec :family jp-font)))
      ;; 日本語入力・表示時の既定コーディングを UTF-8 に統一
      (set-language-environment "Japanese")
      (prefer-coding-system 'utf-8))))

;; --- 日本語入力: Mozc (Google日本語入力相当) ---
;; C-\ で 半角英数 ⇔ 日本語 をトグルする。
(add-to-list 'load-path "/usr/share/emacs/site-lisp/emacs-mozc")
(when (require 'mozc nil t)
  (setq default-input-method "japanese-mozc")
  ;; 変換候補をエコーエリアに表示 (GUI/端末どちらでも安定)
  (setq mozc-candidate-style 'echo-area))

(require 'server)
(unless (server-running-p) (server-start))
;; --- クリップボード連携 (tmux 対応版 OSC 52) ---
(defun my/copy-to-clipboard (text)
  "テキストを Windows のクリップボードへコピーする。日本語対応。
GUI (X/WSLg) では clip.exe に流し込み、端末では OSC 52 を使う。"
  (condition-case nil
      (if (display-graphic-p)
          ;; --- GUI (X/WSLg): 端末が無いので OSC 52 は届かない ---
          ;; clip.exe に UTF-16LE で渡すことで日本語も確実にコピーする。
          (let ((coding-system-for-write 'utf-16le-with-signature)
                (process-connection-type nil))
            (let ((proc (start-process "clip" nil "clip.exe")))
              (process-send-string proc text)
              (process-send-eof proc)))
        ;; --- 端末: OSC 52 (tmux 越しにも対応) ---
        (let* ((encoded-text (encode-coding-string text 'utf-8))
               (b64-text (base64-encode-string encoded-text t))
               (osc52-string (if (getenv "TMUX")
                                 (format "\ePtmux;\e\e]52;c;%s\a\e\\" b64-text)
                               (format "\e]52;c;%s\a" b64-text))))
          (send-string-to-terminal osc52-string)))
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


;; ==========================================
;;  emacs をGUIで開くと文字が小さくなりすぎるのを解消する．ref:https://www.ncaq.net/2024/12/31/14/33/29/
;; ==========================================
(leaf *font
  :init
  (defun font-setup ()
    (set-face-attribute
     'default
     nil
     :family "HackGen Console NF"
     ;; 2画面分割でだいたい横120文字を表示できるフォントサイズにする。
     ;; フルHDと4Kを想定。
     :height (if (<= (frame-pixel-width) 1920) 180 220))
    (set-fontset-font t 'unicode (font-spec :name "HackGen Console NF") nil 'append)
    (unless (eq system-type 'darwin)
      (set-fontset-font t '(#x1F000 . #x1FAFF) (font-spec :name "Noto Color Emoji") nil 'append)))
  ;; `frame-pixel-width'がフレーム作成後でないと実用的な値を返さないので、
  ;; 初期化後にフォントサイズを設定します。
  :hook (window-setup-hook . font-setup))
