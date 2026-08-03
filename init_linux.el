;;; -*- coding: utf-8 -*-
;;; init_linux.el --- Linux / SSH 端末向け設定 -*- lexical-binding: t -*-

;; --- クリップボード連携 ---
;; このマシンは SSH 越しの端末(-nw)で使うことが多い。
;; 端末には X が無く、DISPLAY が SSH 転送先(実在しない X server)を指すため、
;; xclip を無条件に有効化すると C-y のたびに "Can't open display" になる。
;; 対策:
;;   * xclip は GUI フレームのときだけ有効化する(端末では読み込まない)。
;;   * 端末(-nw)では clipetty が kill を OSC 52 で接続元PCのクリップボードへ送る。
;;     → M-w / C-w がそのままローカルのクリップボードにコピーされる。
;;   * 端末→Emacs への貼り付けは端末側のペースト(Ctrl+Shift+V 等)を使う。
;;     C-y は Emacs 自身の kill-ring から貼れる(xclip 不要)。
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; GUI (X) フレームでのみ xclip を使う。端末フレームでは走らせない。
(when (display-graphic-p)
  (leaf xclip
    :require t
    :straight t
    :config
    (xclip-mode 1)))

;; 端末(-nw)向け: clipetty が kill を OSC 52 経由でローカルのクリップボードへ送る。
;; clipetty は端末フレームのときだけ OSC 52 を送るので GUI フレームには干渉しない。
;; tmux / screen の passthrough も自動対応。
(leaf clipetty
  :require t
  :straight t
  :global-minor-mode global-clipetty-mode)

(leaf eshell-git-prompt
  ;; :ensure t
  :require t
  :straight t
  :config
  (eshell-git-prompt-use-theme 'git-radar))


;; C-z で Emacs をサスペンドする
(global-set-key (kbd "C-z") 'suspend-emacs)

;; --- 日本語入力: Mozc (Google日本語入力相当) ---
;; C-\ で 半角英数 ⇔ 日本語 をトグルする。
(add-to-list 'load-path "/usr/share/emacs/site-lisp/emacs-mozc")
(when (require 'mozc nil t)
  (setq default-input-method "japanese-mozc")
  ;; 変換候補をエコーエリアに表示 (GUI/端末どちらでも安定)
  (setq mozc-candidate-style 'echo-area))

(require 'server)

(defun my/start-server-after-startup ()
  "Start Emacs server after command-line files are already displayed."
  (run-at-time
   1 nil
   (lambda ()
     (unless (bound-and-true-p server-process)
       (condition-case err
           (server-start)
         (error
          (message "server-start failed: %s" (error-message-string err)))))
     (when (and (boundp 'server-socket-dir)
                server-socket-dir
                (boundp 'server-name)
                server-name)
       (setenv "EMACS_SOCKET_NAME"
               (expand-file-name server-name server-socket-dir))))))

(add-hook 'emacs-startup-hook #'my/start-server-after-startup)

(setenv "EMACS_SOCKET_NAME" "/run/user/1000/emacs/server")
(setenv "EMACS_SERVER_FILE" "/run/user/1000/emacs/server")
(setenv "XDG_RUNTIME_DIR" "/run/user/1000")
