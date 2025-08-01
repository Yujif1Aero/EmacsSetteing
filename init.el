(setq debug-on-error t)

;; 失敗するキー文字列を必ずログに出す
(advice-add 'read-kbd-macro :around
  (lambda (orig str &optional need-vector)
    (condition-case err
        (funcall orig str need-vector)
      (error
       (message "[read-kbd-macro] BAD: %S" str)
       (signal (car err) (cdr err))))))

(advice-add 'kbd :around
  (lambda (orig str)
    (condition-case err
        (funcall orig str)
      (error
       (message "[kbd] BAD: %S" str)
       (signal (car err) (cdr err))))))

;; ★ 修正版：可変長引数で受ける
(advice-add 'define-key :around
  (lambda (orig &rest args)
    (condition-case err
        (apply orig args)
      (error
       (message "[define-key] BAD args=%S" args)
       (signal (car err) (cdr err))))))

;; Emacs 28+ の高レベルAPIも捕まえる
(dolist (f '(keymap-set keymap-global-set))
  (when (fboundp f)
    (advice-add f :around
      (lambda (orig &rest args)
        (condition-case err
            (apply orig args)
          (error
           (message "[%s] BAD args=%S" orig args)
           (signal (car err) (cdr err))))))))

;;; init.el --- Unified Emacs config with OS-specific parts -*- lexical-binding: t -*-
;;; ---- TOP OF init.el ----
(setq package-enable-at-startup nil)       ;; 競合防止（early-init.elでもOK）
(setq straight-use-package-by-default t)   ;; 以後 :straight を省略可

;; straight.el bootstrap
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; <- ここが重要：:straight を use-package が認識できるようにする
(straight-use-package 'use-package)
(require 'use-package)

;; leaf を使う場合はここで読み込む
(straight-use-package 'leaf)
(straight-use-package 'leaf-keywords)
(require 'leaf)
(require 'leaf-keywords)
(leaf-keywords-init)
;;; ---- ここまでを必ず最上部に ----

;; あなたの共通/OS別設定を読み込む
(load (expand-file-name "init_common.el" user-emacs-directory) t)
(load (expand-file-name "init_linux.el"  user-emacs-directory) t)

;; 共通設定の読み込み
(load (expand-file-name "init_common.el" user-emacs-directory))

;; OS 判定関数（WSL用）
(defun running-in-wsl-p ()
  "WSL 上で Emacs が動作しているかを判定する"
  (and (eq system-type 'gnu/linux)
       (string-match "Microsoft" (shell-command-to-string "uname -r"))))

;; OSごとの設定読み込み
(cond
 ((running-in-wsl-p)
  (message "Loading WSL2-specific settings...")
  (load (expand-file-name "init_WSL2.el" user-emacs-directory)))

 ((eq system-type 'gnu/linux)
  (message "Loading linux-specific settings...")
  (load (expand-file-name "init_linux.el" user-emacs-directory))))
