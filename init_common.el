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
;; ==========================================
;; tmux/ターミナル環境での自動クリップボード同期を強制遮断
;; ==========================================
(unless (display-graphic-p)
  ;; Emacs 25以降のターミナルでの自動クリップボード連携をオフ
  (setq xterm-select-enable-clipboard nil)
  
  ;; ペースト時に外部（tmux等）のクリップボードを見に行く関数を無効化
  (setq interprogram-paste-function nil)
  
  ;; コピー（キル）時に外部へ送信する関数を無効化（もっさり対策）
  (setq interprogram-cut-function nil))

;; (unless (display-graphic-p)
;;   (setq interprogram-cut-function (lambda (text) (my/copy-to-clipboard text) nil)))
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
(leaf magit
  :straight t
  :bind ((magit-mode-map
          ("C-n" . next-line)
          ("C-p" . previous-line)
          ("C-c C-n" . magit-section-forward)
          ("C-c C-p" . magit-section-backward))
         ("C-c g" . magit-diff-working-tree))
  :custom
  (magit-save-repository-buffers . nil)
  (magit-display-buffer-function . #'magit-display-buffer-same-window-except-diff-v1)
  
  ;; --- 高速化のための追加設定 ---
  (magit-refresh-status-buffer . nil)      ; 自動更新をオフ（必要な時だけ 'g' で更新）
  (magit-diff-highlight-indentation . nil) ; インデントのハイライトをオフ
  (magit-diff-highlight-trailing . nil)    ; 行末空白の強調をオフ
  (magit-commit-show-diffstat . nil)       ; コミット時の統計表示をオフ
  
  :config
  ;; Git側の動作を最適化する引数
  (setq magit-git-global-arguments 
        '("-c" "core.preloadIndex=true" 
          "-c" "core.fscache=true" 
          "-c" "gc.auto=0"))
  )
;;ccls を導入
(leaf ccls
  ;;  :ensure t
  :straight t
  :after lsp-mode
  :init
  (setq ccls-executable "/usr/bin/ccls")  ;; cclsの実行可能ファイルのパスを適切に設定
  :config
  (setq lsp-enable-snippet nil
        lsp-enable-semantic-highlighting t
        lsp-ccls-enable t))

(leaf lsp-mode
  ;;  :ensure t
  :straight t
  :commands lsp
  :init
  ;; LSP 全般の設定
  (setq lsp-clients-clangd-args nil) ;; clangd 設定を無効化
  :config
  ;; キーバインド
  (define-key lsp-mode-map (kbd "M-.") #'lsp-find-definition)
  (define-key lsp-mode-map (kbd "M-,") #'lsp-find-references)
  (define-key lsp-mode-map (kbd "M-s") #'lsp-find-implementation)
  (define-key lsp-mode-map (kbd "M-t") #'lsp-find-declaration)
  ;; Python 用 LSP 手動起動
  (defun my/lsp-start-python ()
    "Manually start LSP for Python."
    (interactive)
    (require 'lsp-pyright)
    (lsp))
  ;; Python モードで簡単に起動
  ;; (add-hook 'python-mode-hook
  ;;           (lambda ()
  ;;             (local-set-key (kbd "C-c l") 'my/lsp-start-python)))
  ;;   ;; 必要に応じて他の言語用関数も追加可能
  )

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
(leaf treemacs-evil
  :after (treemacs evil)
  ;; :ensure t
  :straight t
  )

(leaf treemacs-projectile
  :after (treemacs projectile)
  :straight t
;;  :ensure t
  )

(leaf treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  ;; :ensure t
  :straight t
  )

(leaf treemacs-magit
  :after (treemacs magit)
  ;;  :ensure t
  :straight t
  )

(leaf treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  ;;  :ensure t
  :straight t
  :config (treemacs-set-scope-type 'Perspectives))

(leaf treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  ;;  :ensure t
  :straight t
  :config (treemacs-set-scope-type 'Tabs))


;;インデント揃え
(global-set-key (kbd "C-c C-r") 'indent-region)
(leaf helm-ag
  :load-path "~/.emacs.d/helm-ag"
  ;; :ensure t
  :straight t
  :after helm
  :custom
  (helm-ag-base-command . "ag --nocolor --nogroup")
  (helm-ag-insert-at-point . 'symbol)
  (helm-ag-command-option . "--all-text")
  (helm-ag-fuzzy-match . t)
  :bind (("C-c p 1" . helm-ag)
         ("C-c p SPC" . helm-do-ag))
  :config
  (with-eval-after-load 'helm-ag
    (define-key helm-ag-edit-map (kbd "RET") 'compile-goto-error)))


(leaf projectile
;;  :ensure t
  :straight t
  :require t
  :config
  (progn
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
    (projectile-mode +1)
    ;; ;; プロジェクトのルートディレクトリに `default-directory` を設定する関数を追加
    (defun set-default-directory-to-project-root ()
      "Set `default-directory` to the root of the project."
      (let ((project-root (projectile-project-root)))
        (when project-root
          (setq default-directory project-root))))

    ;; ;; ;; find-file-hook に関数を追加
    (add-hook 'find-file-hook 'set-default-directory-to-project-root)
    )
  )

(leaf helm-projectile
  ;;  :ensure t
  :straight t
  :after (helm projectile)
  :config
  (helm-projectile-on)
  (setq projectile-completion-system 'helm)
  :bind
  (("C-c p h" . helm-projectile)
   ("C-c p n" . helm-projectile-grep)
   )
  )

(leaf diff-hl
  :straight t
;;  :ensure t
  :config
  (global-diff-hl-mode)
  ;; ターミナルの場合、行の背景色を使うように設定
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1)))
;; 保存時に更新
(add-hook 'after-save-hook 'diff-hl-update)

;; バッファ切り替え時に更新
(add-hook 'focus-in-hook 'diff-hl-update)

(fringe-mode '(8 . 8))

;; shell-popの設定
(leaf shell-pop
;;  :ensure t
  :straight t
  :require t
  :custom
  (shell-pop-shell-type . '("eshell" "*eshell*" (lambda () (eshell))))
  ;; (shell-pop-shell-type . '("term" "*term*" (lambda () (term "/run/current-system/sw/bin/zsh"))))
  ;; (shell-pop-shell-type . '("term" "*term*" (lambda () (term "/bin/bash"))))
  ;; 例: (shell-pop-window-size . 30) ; ウィンドウのサイズを30%に設定
  ;;     (shell-pop-full-span . t) ; フル幅で表示
  :bind
  (("C-t" . shell-pop)))

;; eshell-specific settings
(add-hook 'eshell-mode-hook
          (lambda ()
            (define-key eshell-mode-map (kbd "<tab>") 'completion-at-point)))
;; Eshell用にcdpjrootエイリアスを設定
(defun eshell/cdpjroot ()
  "Change directory to the root of the Git repository in Eshell."
  (let ((git-root (string-trim (shell-command-to-string "git rev-parse --show-toplevel"))))
    (eshell/cd git-root)))  ;; eshellのcdコマンドを使う

;; helmをeshellで無効化する設定
(defun my/eshell-disable-helm ()
  "Disable helm completion in eshell."
  (setq-local helm-mode-no-completion-in-region-in-modes '(eshell-mode)))
(add-hook 'eshell-mode-hook 'my/eshell-disable-helm)
;; eshell からファイルを開く.
(with-eval-after-load 'eshell
  (defun setup-eshell-aliases ()
    (eshell/alias "emacs" "find-file $1")
    (eshell/alias "m" "find-file $1")
    (eshell/alias "mc" "find-file $1"))
  (add-hook 'eshell-mode-hook 'setup-eshell-aliases))

(setq enable-local-variables t)

;; AI・ツール連携
(leaf copilot :if (executable-find "node") :straight (copilot :type git :host github :repo "zerolfx/copilot.el" :files ("*.el"))
  :commands (copilot-mode) :bind (("C-c M-f" . copilot-mode)))
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


(leaf diff-hl
  :straight t
;;  :ensure t
  :config
  (global-diff-hl-mode)
  ;; ターミナルの場合、行の背景色を使うように設定
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1)))
;; 保存時に更新
(add-hook 'after-save-hook 'diff-hl-update)

;; バッファ切り替え時に更新
(add-hook 'focus-in-hook 'diff-hl-update)

(fringe-mode '(8 . 8))

;; shell-popの設定
(leaf shell-pop
;;  :ensure t
  :straight t
  :require t
  :custom
  (shell-pop-shell-type . '("eshell" "*eshell*" (lambda () (eshell))))
  ;; (shell-pop-shell-type . '("term" "*term*" (lambda () (term "/run/current-system/sw/bin/zsh"))))
  ;; (shell-pop-shell-type . '("term" "*term*" (lambda () (term "/bin/bash"))))
  ;; 例: (shell-pop-window-size . 30) ; ウィンドウのサイズを30%に設定
  ;;     (shell-pop-full-span . t) ; フル幅で表示
  :bind
  (("C-t" . shell-pop)))

;; eshell-specific settings
(add-hook 'eshell-mode-hook
          (lambda ()
            (define-key eshell-mode-map (kbd "<tab>") 'completion-at-point)))
;; Eshell用にcdpjrootエイリアスを設定
(defun eshell/cdpjroot ()
  "Change directory to the root of the Git repository in Eshell."
  (let ((git-root (string-trim (shell-command-to-string "git rev-parse --show-toplevel"))))
    (eshell/cd git-root)))  ;; eshellのcdコマンドを使う

;; helmをeshellで無効化する設定
(defun my/eshell-disable-helm ()
  "Disable helm completion in eshell."
  (setq-local helm-mode-no-completion-in-region-in-modes '(eshell-mode)))
(add-hook 'eshell-mode-hook 'my/eshell-disable-helm)
;; eshell からファイルを開く.
(with-eval-after-load 'eshell
  (defun setup-eshell-aliases ()
    (eshell/alias "emacs" "find-file $1")
    (eshell/alias "m" "find-file $1")
    (eshell/alias "mc" "find-file $1"))
  (add-hook 'eshell-mode-hook 'setup-eshell-aliases))



(defun my-python-comment-dwim (arg)
  "Comment or uncomment current line or region with #ys in Python mode."
  (interactive "*P")
  (let ((comment-start "#ys "))
    (if (use-region-p)
        (comment-dwim arg)
      (save-excursion
        (beginning-of-line)
        (if (looking-at (concat "^\\s-*" (regexp-quote comment-start)))
            (uncomment-region (line-beginning-position) (line-end-position))
          (progn
            (beginning-of-line)
            (insert comment-start)))))))

(defun my-python-comment-style ()
  (setq comment-start "#ys "
        comment-end ""))

(add-hook 'python-mode-hook 'my-python-comment-style)
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "M-;") 'my-python-comment-dwim)))



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
