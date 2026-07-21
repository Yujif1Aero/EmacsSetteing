(leaf xclip
;;  :ensure t

  :require t
  :straight t
  :config
  ;; xclip-mode を有効にする
  (xclip-mode 1))

;; (when (display-graphic-p)
;;   (leaf xclip
;;     :require t
;;     :straight t
;;     :config
;;     (xclip-mode 1)))


(setq select-enable-clipboard t)
(setq select-enable-primary t)

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

