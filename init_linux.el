;; 端末(非GUI)でのマウス
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; --- クリップボード設定 ---
(leaf clipetty
  :straight t
  :when (not (display-graphic-p))        ; TTY だけ
  :config (global-clipetty-mode 1))      ; Emacs → ローカル に OSC52 でコピー

(leaf xclip
  :straight t
  :when (display-graphic-p)              ; GUI のときだけ
  :config (xclip-mode 1))

;; TTY では念のため xclip を必ず OFF（DISPLAY が見えていても切る）
(unless (display-graphic-p)
  (with-eval-after-load 'xclip (xclip-mode -1)))


;;(setq select-enable-primary t)


(leaf eshell-git-prompt
  :straight t
  :config
  (eshell-git-prompt-use-theme 'git-radar))


;; C-z で Emacs をサスペンドする
(global-set-key (kbd "C-z") 'suspend-emacs)


