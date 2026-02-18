;;; -*- coding: utf-8 -*-
;;; init_common.el --- あなたの設定を完全に保持した高速・日本語対応版

(setq debug-on-error nil)
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

;; --- クリップボード連携 (tmux 対応版 OSC 52) ---
(defun my/copy-to-clipboard (text)
  "OSC 52 を使い、tmux 越しでも Windows へコピーする。日本語対応。"
  (condition-case nil
      (let* ((encoded-text (encode-coding-string text 'utf-8))
             (b64-text (base64-encode-string encoded-text t))
             ;; tmux 内にいる場合は専用のシーケンスで包む
             (osc52-string (if (getenv "TMUX")
                               (format "\ePtmux;\e\e]52;c;%s\a\e\\" b64-text)
                             (format "\e]52;c;%s\a" b64-text))))
        (send-string-to-terminal osc52-string))
    (error nil)))

(unless (display-graphic-p)
  (setq interprogram-cut-function (lambda (text) (my/copy-to-clipboard text) nil)))
(defun yujif1aero/add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
             (expand-file-name (concat user-emacs-directory path))))
        (unless (file-exists-p default-directory)
          (make-directory default-directory))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

(yujif1aero/add-to-load-path "elisp" "conf")

;; Emacs自体が書き込む設定先の変更
(setq custom-file (locate-user-emacs-file "custom.el"))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

;; straight.el & leaf setup
(setq straight-enable-use-package-integration nil)
(setq straight-repository-branch "develop")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(setq straight-vc-git-default-clone-depth 1)

(straight-use-package 'cond-let)
(straight-use-package 'leaf)
(straight-use-package 'leaf-keywords)
(require 'leaf)
(leaf leaf-keywords :config (leaf-keywords-init))

;; あなたのパッケージ設定 (Hydra, el-get, leaf-tree, blackout, gcmh等)
(leaf hydra :straight t)
(leaf el-get :straight t :custom '((el-get-git-shallow-clone . t)))
(leaf leaf :require t :init (leaf leaf-convert :straight t) (leaf leaf-tree :straight t :blackout t :custom (imenu-list-position . 'left)))
(leaf blackout :leaf-defer nil :straight t :config (leaf eldoc :blackout t))
(leaf Libraries :config (leaf cl-lib :leaf-defer t) (leaf dash :straight t :leaf-defer t))
(leaf gcmh :leaf-defer nil :straight t :blackout t :global-minor-mode gcmh-mode)

(dolist (frame (frame-list)) (modify-frame-parameters frame '((cursor-type . box))))
(electric-pair-mode 1)
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(global-set-key "\C-x\C-b" 'buffer-menu)
(define-key global-map (kbd "C-c o") 'other-window)
(leaf *truncate-lines :bind ("M-z" . toggle-truncate-lines))
(global-font-lock-mode t)
(setq-default line-spacing 0)

;; 日本語・置換関数設定
(show-paren-mode t)
(setq its-hira-period "．")
(setq its-hira-comma "，")
(defun replace-kv-region (l) (save-excursion (save-restriction (narrow-to-region b e) (format-replace-strings l))))
(defun query-replace-strings (a) (dolist (i a) (goto-char b) (query-replace (car i) (cdr i))))
(defun query-replace-kv-region (l) (save-excursion (save-restriction (narrow-to-region b e) (query-replace-strings l))))

(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)

(leaf mozc :if (executable-find "mozc_emacs_helper") :config (setq default-input-method "japanese-mozc" mozc-candidate-style 'overlay))

;; 句読点変換ショートカット設定
(defconst kutoten-zenpunct-kv '(("。" . "．") ("、" . "，")))
(defconst zenpunct-kutoten-kv '(("．" . "。") ("，" . "、")))
(defun replace-kutoten-zenpunct-region (b e) (interactive "r") (replace-kv-region kutoten-zenpunct-kv))
(global-set-key "\C-x\C-m/" 'replace-kutoten-zenpunct-region)

(leaf undo-tree :straight t :leaf-defer nil :bind (("M-/" . undo-tree-redo)) :custom ((global-undo-tree-mode . t)))
(leaf whitespace :straight t :custom ((whitespace-style . '(face trailing tabs space-mark tab-mark)) (global-whitespace-mode . t)))
(setq-default indent-tabs-mode nil) (setq-default tab-width 4) (global-set-key (kbd "TAB") 'tab-to-tab-stop)

;; 見た目設定 (Gruvbox, line-numbers等)
(leaf gruvbox-theme :straight t :config (load-theme 'gruvbox-dark-medium t))
(leaf display-line-numbers :config (global-display-line-numbers-mode t))
(menu-bar-mode 0) (tool-bar-mode 0) (scroll-bar-mode -1) (which-function-mode 1) (setq frame-title-format "%f")

;; Elscreen 設定
(leaf elscreen :straight t :init (setq elscreen-prefix-key (kbd "C-M-z")) (elscreen-start)
  :bind (("C-M-t" . elscreen-create) ("C-M-l" . elscreen-next) ("C-M-r" . elscreen-previous) ("C-M-c" . my/elscreen-kill-with-confirmation)))

;; 操作性・windmove (Ctrl+矢印)
(xterm-mouse-mode 1)
(mouse-wheel-mode 1)

;; マウスホイールのスクロール設定
(setq mouse-wheel-scroll-amount '(10 ((shift) . 1) ((control) . nil))) ;; 通常1行、Shiftで1行、Ctrlでページ単位
(setq mouse-wheel-progressive-speed nil) ;; スクロール速度を固定（加速しない）
(setq mouse-wheel-follow-mouse 't)      ;; マウスポインタの位置のウィンドウをスクロール

;; スムーズスクロールの設定
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)

;; 画面端まで行っても1行ずつスクロールさせる（お好みで）
(setq scroll-margin 0)
;;スクロールの加速
(setq mouse-wheel-progressive-speed t)
(global-set-key (kbd "<C-left>")  'windmove-left)
(global-set-key (kbd "<C-down>")  'windmove-down)
(global-set-key (kbd "<C-up>")    'windmove-up)
(global-set-key (kbd "<C-right>") 'windmove-right)

;; 検索・開発 (Magit, LSP, Company, Helm, Projectile等)
(leaf magit :straight t :custom (magit-refresh-status-buffer . nil))
(leaf lsp-mode :straight t :commands lsp :config (define-key lsp-mode-map (kbd "M-.") #'lsp-find-definition))
(leaf company :straight t :init (global-company-mode) :custom (company-idle-delay . 0.2))
(leaf which-key :straight t :config (which-key-mode) (which-key-setup-side-window-right))
(leaf helm
  :straight t
  :config
  (helm-mode 1)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)

  (with-eval-after-load 'helm-files
    ;; TABキーの挙動を「アクションメニュー」から「補完・展開」に変更
    ;; これにより、ディレクトリなら中に入り、名前がユニークなら補完されます
    (define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
    (define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
    
    ;; ターミナル環境（C-i と TAB が同じ扱い）への対策
    (define-key helm-find-files-map (kbd "C-i") 'helm-execute-persistent-action)
    
    ;; 元々TABにあった「アクションメニュー」を C-z に割り当て
    (define-key helm-map (kbd "C-z") 'helm-select-action)
    (define-key helm-find-files-map (kbd "C-z") 'helm-select-action))

  ;; ファイル名の補完時に「.」や「..」を表示させない（Diredに近く、視認性を上げる設定）
  (setq helm-ff-skip-boring-files t))
(leaf projectile :straight t :config (projectile-mode +1) (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))
(leaf helm-projectile :straight t :after (helm projectile) :config (helm-projectile-on))

;; AI・ツール連携
(leaf copilot :if (executable-find "node") :straight (copilot :type git :host github :repo "zerolfx/copilot.el" :files ("*.el"))
  :commands (copilot-mode) :bind (("C-c M-f" . copilot-mode)))
(leaf shell-pop :straight t :bind (("C-t" . shell-pop)))
(leaf clang-format :straight t :bind (("C-c C-_" . clang-format-region) ("C-c /" . clang-format-buffer)))

;; --- 【新規追加】C-c d と C-c C-d でカレントディレクトリを移動 ---
(defun my/set-cwd-to-current-file ()
  "開いているファイルの場所に cd します。"
  (interactive)
  (if (buffer-file-name)
      (let ((dir (file-name-directory (buffer-file-name)))) (cd dir) (message "Changed cwd to: %s" dir))
    (message "Not visiting a file")))
(global-set-key (kbd "C-c d") 'my/set-cwd-to-current-file)
(global-set-key (kbd "C-c C-d") 'my/set-cwd-to-current-file)

(leaf markdown-mode :straight t :mode ("\\.md\\'" . markdown-mode))


;; 選択範囲を tab幅ぶん右/左にずらす
(defun my/indent-shift-right (beg end)
  (interactive "r")
  (indent-rigidly beg end tab-width))

(defun my/indent-shift-left (beg end)
  (interactive "r")
  (indent-rigidly beg end (- tab-width)))

;; 好きなキーに割り当て（例：C-c ] / C-c [）
(global-set-key (kbd "C-c ]") #'my/indent-shift-right)
(global-set-key (kbd "C-c [") #'my/indent-shift-left)


;;; ============================================================
;;; Emacs Lisp (.el) 用：手動整形 (C-c / , C-c C-_)
;;; ============================================================

(defun my/elisp-format-region (beg end)
  "Emacs Lisp の選択範囲を整形する（インデント + 行末空白削除）。"
  (interactive "r")
  (save-excursion
    (indent-region beg end)
    (delete-trailing-whitespace beg end)))

(defun my/elisp-format-buffer ()
  "Emacs Lisp のバッファ全体を整形する（インデント + 行末空白削除）。"
  (interactive)
  (my/elisp-format-region (point-min) (point-max)))

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            ;; バッファ全体
            (local-set-key (kbd "C-c /") #'my/elisp-format-buffer)

            ;; 範囲（C-_ が環境によって入りにくい時があるので C-/ も保険で同じに）
            (local-set-key (kbd "C-c C-_") #'my/elisp-format-region)
            (local-set-key (kbd "C-c C-/") #'my/elisp-format-region)))

;; （任意）*scratch* などでも同じキーで整形したいなら
(add-hook 'lisp-interaction-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c /") #'my/elisp-format-buffer)
            (local-set-key (kbd "C-c C-_") #'my/elisp-format-region)
            (local-set-key (kbd "C-c C-/") #'my/elisp-format-region)))



;;; ============================================================
;;; Python用：Blackによる自動整形 (C-c /)
;;; ============================================================
(leaf python-black
  :straight t
  :after python
  :config
  (add-hook 'python-mode-hook
            (lambda ()
              ;; バッファ全体を整形 (C-c /)
              (local-set-key (kbd "C-c /") #'python-black-buffer)
              ;; 選択範囲を整形 (C-c C-_)
              (local-set-key (kbd "C-c C-_") #'python-black-region))))



(defun my-c-comment-dwim (arg)
  "Comment or uncomment current line or region with //ys in C and C++ modes."
  (interactive "*P")
  (let ((comment-start "//ys ")
        (comment-end ""))
    (if (use-region-p)
        (comment-dwim arg)
      (save-excursion
        (beginning-of-line)
        (if (looking-at (concat "^\\s-*" (regexp-quote comment-start)))
            (uncomment-region (line-beginning-position) (line-end-position))
          (progn
            (beginning-of-line)
            (insert comment-start)))))))
(defun my-c-comment-style ()
  (setq comment-start "//ys "
        comment-end ""))
