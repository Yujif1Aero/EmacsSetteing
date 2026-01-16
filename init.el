;;; init.el --- Unified Emacs config with OS-specific parts -*- lexical-binding: t -*-

;; 1.
(load (expand-file-name "init_common.el" user-emacs-directory))

;; 2. OS
(defun running-in-wsl-p ()
  "WSL  Emacs "
  (and (eq system-type 'gnu/linux)
       (string-match "Microsoft" (shell-command-to-string "uname -r"))))

;; 3. OS
(cond
 ;; WSL2 (Ubuntu on Windows)
 ((running-in-wsl-p)
  (message "Loading WSL2-specific settings...")
  (load (expand-file-name "init_WSL2.el" user-emacs-directory)))

 ;; Windows (Native)
 ((eq system-type 'windows-nt)
  (message "Loading Windows-specific settings...")
  (load (expand-file-name "init_windows.el" user-emacs-directory)))

 ;;  Linux
 ((eq system-type 'gnu/linux)
  (message "Loading linux-specific settings...")
    (load (expand-file-name "init_linux.el" user-emacs-directory))))
