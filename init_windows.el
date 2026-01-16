;;;; init_windows.el --- Settings for Native Windows

;; ---  ---
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; Windows (MS932/CP932)
(set-terminal-coding-system 'cp932)
(set-keyboard-coding-system 'cp932)
(setq file-name-coding-system 'cp932)

;; ---  ---
;; Windows Git (git.exe)
(when (executable-find "git.exe")
  (setq magit-git-executable "git.exe"))

;; Windows
(setq browse-url-browser-function 'browse-url-default-windows-browser)

;; ---  ---
;; :
(when (window-system)
  (set-face-attribute 'default nil :family "Meiryo" :height 105))

;; ---  ---
;; shell-pop  PowerShell
(leaf shell-pop
  :straight t
  :custom
  (shell-pop-shell-type . '("powershell" "*powershell*" (lambda () (powershell)))))

(message "init_windows.el has been loaded.")
