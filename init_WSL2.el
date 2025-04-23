

;;; Copy and Paste parameters

(global-set-key (kbd "C-c M-w") 'osc52-send-region-to-clipboard)

(defun smart-copy-to-windows-clipboard (start end)

  "Copy region to both kill ring and Windows clipboard, adjusting for GUI or TUI."

  (interactive "r")

  (when (use-region-p)

    (kill-ring-save start end)

    (let ((text (buffer-substring-no-properties start end)))

      (cond

       ;; GUI (WSLg)

       ((display-graphic-p)

        (let ((process-connection-type nil))

          (let ((proc (start-process "xclip" nil "xclip" "-selection" "clipboard")))

            (process-send-string proc text)

            (process-send-eof proc))))

       ;; TUI (`emacs -nw`) use clip.exe

       (t

        (let ((process-connection-type nil))

          (let ((proc (start-process "clip.exe" nil "clip.exe")))

            (process-send-string proc text)

            (process-send-eof proc))))))))

(global-set-key (kbd "M-w") #'smart-copy-to-windows-clipboard)

;;;;

(setq select-enable-clipboard t)

(setq select-enable-primary t)


;; eshell-git-promptの設定

(leaf eshell-git-prompt

  :ensure t

  :config

  (eshell-git-prompt-use-theme 'powerline))

