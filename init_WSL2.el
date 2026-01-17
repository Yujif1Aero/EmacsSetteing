;;; -*- coding: utf-8 -*-
;;; init_WSL2.el --- WSL2専用設定（文字化け・エラー修正版）

;; =============================================================================
;; 1. 文字化けしないクリップボード連携
;; =============================================================================

(defun smart-copy-to-windows-clipboard (start end)
  "WSLからWindowsへ文字化けせずにコピーする（決定版）。"
  (interactive "r")
  (if (use-region-p)
      (let ((text (buffer-substring-no-properties start end)))
        ;; Emacs内部のキルリングに保存
        (kill-new text)
        ;; PowerShell経由で送信。送信時の文字コードを utf-8 に固定
        (let ((coding-system-for-write 'utf-8-unix)
              (process-connection-type nil))
          (let ((proc (start-process "powershell-clip" nil "powershell.exe" 
                                     "-NoProfile" "-Command" 
                                     ;; PowerShellに入力エンコーディングをUTF-8にするよう強制し、
                                     ;; 標準入力([Console]::In)を最後まで読み取ってクリップボードへ送る
                                     "[Console]::InputEncoding = [System.Text.Encoding]::UTF8; [Console]::In.ReadToEnd() | Set-Clipboard")))
            (process-send-string proc text)
            (process-send-eof proc)))
        (deactivate-mark)
        (message "Windowsクリップボードにコピーしました"))
    (message "エラー：範囲が選択されていません")))
;; M-w に割り当て
(global-set-key (kbd "M-w") #'smart-copy-to-windows-clipboard)

;; =============================================================================
;; 2. eshell-git-prompt のエラー修正
;; =============================================================================

(leaf eshell-git-prompt
  :straight t
  :require t
  :config
  (when (fboundp 'eshell-git-prompt-use-theme)
    (eshell-git-prompt-use-theme 'powerline)))

;; =============================================================================
;; 3. Magit のエラー回避設定 (void-variable 対策)
;; =============================================================================

;; 変数が定義されていないエラーを防ぐため、Magitがロードされた後に設定を実行する
(with-eval-after-load 'magit
  (setenv "GIT_EDITOR" "notepad.exe")
  ;; 既存の引数に notepad.exe の設定を追加
  (setq magit-git-global-arguments 
        (append magit-git-global-arguments '("-c" "core.editor=notepad.exe"))))

;; =============================================================================
;; 4. その他環境設定
;; =============================================================================

(setq select-enable-clipboard t)
(setq select-enable-primary t)


;; 1. ピクセル単位でサイズ調整を許可（左右スナップ時の黒い隙間を完全に解消）
(setq frame-resize-pixelwise t)

;; 2. 起動時に最初から最大化して表示領域を確保する
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; 3. GUI起動時の見た目調整（文字サイズを大きくして「安っぽさ」を解消）
(when (display-graphic-p)
  (set-face-attribute 'default nil :height 140) ;; 高解像度なら 140-150 がおすすめ
  (set-scroll-bar-mode nil) ;; GUIの古いスクロールバーを消す
  (set-fringe-mode 8))    ;; 左右に適切な余白を作る
(message "init_WSL2.el has been loaded successfully.")
;; 逆引きジャンプを受け取るためのサーバーを起動
(require 'server)
(unless (server-running-p)
  (server-start))
