;;; -*- coding: utf-8 -*-
;;; init_common.el --- あなたの設定を完全に保持した高速・日本語対応版 (爆速最適化済)

(setq debug-on-error nil)
(when (< emacs-major-version 23)
    (defvar user-emacs-directory "~/.emacs.d/"))

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

;; ==========================================
;; straight.el 起動高速化設定
;; ==========================================
(setq straight-enable-use-package-integration nil)
(setq straight-repository-branch "develop")
(setq straight-vc-git-default-clone-depth 1)
;; 【重要】起動時の変更チェックを最小限にして爆速化
(setq straight-check-for-modifications '(check-hashes find-when-checking))

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

(straight-use-package 'cond-let)
(straight-use-package 'leaf)
(straight-use-package 'leaf-keywords)
(require 'leaf)
(leaf leaf-keywords :config (leaf-keywords-init))

;; 基本パッケージ
(leaf hydra :straight t :leaf-defer t)
(leaf el-get :straight t :leaf-defer t :custom ((el-get-git-shallow-clone . t)))
(leaf leaf :require t :init (leaf leaf-convert :straight t) (leaf leaf-tree :straight t :blackout t :custom (imenu-list-position . 'left)))
(leaf blackout :straight t :config (leaf eldoc :blackout t))
(leaf Libraries :config (leaf cl-lib :leaf-defer t) (leaf dash :straight t :leaf-defer t))
(leaf gcmh :straight t :blackout t :global-minor-mode gcmh-mode)

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
(defun replace-kv-region (b e l)
    ;; lexical-binding 下で未束縛の b/e を参照しないよう、範囲を明示的に受け取る。
    (save-excursion
        (save-restriction
            (narrow-to-region b e)
            (format-replace-strings l))))
(defun query-replace-strings (b a)
    ;; 各置換を同じリージョン先頭から始めるため、呼び出し側から開始位置を渡す。
    (dolist (i a)
        (goto-char b)
        (query-replace (car i) (cdr i))))
(defun query-replace-kv-region (b e l)
    ;; replace-kv-region と同じ範囲指定 API に揃え、対話置換でも未束縛変数を避ける。
    (save-excursion
        (save-restriction
            (narrow-to-region b e)
            (query-replace-strings b l))))

(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)

(leaf mozc :if (executable-find "mozc_emacs_helper") :leaf-defer t :config (setq default-input-method "japanese-mozc" mozc-candidate-style 'overlay))

;; 句読点変換ショートカット設定
(defconst kutoten-zenpunct-kv '(("。" . "．") ("、" . "，")))
(defconst zenpunct-kutoten-kv '(("．" . "。") ("，" . "、")))

(defun replace-kutoten-zenpunct-region (b e) (interactive "r") (replace-kv-region b e kutoten-zenpunct-kv))
(defun replace-zenpunct-kutoten-region (b e)
    (interactive "r")
    ;; 逆変換も同じ API で用意し、定義済みの zenpunct-kutoten-kv を未使用のまま残さない。
    (replace-kv-region b e zenpunct-kutoten-kv))
(global-set-key "\C-x\C-m/" 'replace-kutoten-zenpunct-region)
(global-set-key "\C-x\C-m\\" 'replace-zenpunct-kutoten-region)

(leaf undo-tree :straight t :leaf-defer t :bind (("M-/" . undo-tree-redo)) :global-minor-mode global-undo-tree-mode)
(leaf whitespace :straight t :leaf-defer t :global-minor-mode global-whitespace-mode :custom ((whitespace-style . '(face trailing tabs space-mark tab-mark))))
(setq-default indent-tabs-mode nil) (setq-default tab-width 4) (global-set-key (kbd "TAB") 'tab-to-tab-stop)

;; 見た目設定
(leaf gruvbox-theme :straight t :config (load-theme 'gruvbox-dark-medium t))
(leaf display-line-numbers :global-minor-mode global-display-line-numbers-mode)
(menu-bar-mode 0) (tool-bar-mode 0) (scroll-bar-mode -1) (which-function-mode 1) (setq frame-title-format "%f")

;; Elscreen 設定
(leaf elscreen :straight t :leaf-defer t :init (setq elscreen-prefix-key (kbd "C-M-z")) (elscreen-start)
    :bind (("C-M-t" . elscreen-create) ("C-M-l" . elscreen-next) ("C-M-r" . elscreen-previous) ("C-M-c" . my/elscreen-kill-with-confirmation)))

;; 操作性・スクロール・windmove
;; xterm-mouse-mode は端末用。GUI では不要な minor mode を起動しない。
(unless (display-graphic-p)
    (xterm-mouse-mode 1))
(mouse-wheel-mode 1)
(setq mouse-wheel-scroll-amount '(10 ((shift) . 1) ((control) . nil)))
;; ホイール加速は有効にして、長いバッファでは少ない操作で移動できるようにする。
(setq mouse-wheel-follow-mouse 't)
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)
(setq scroll-margin 0)
(setq mouse-wheel-progressive-speed t)
(global-set-key (kbd "<C-left>")  'windmove-left)
(global-set-key (kbd "<C-down>")  'windmove-down)
(global-set-key (kbd "<C-up>")    'windmove-up)
(global-set-key (kbd "<C-right>") 'windmove-right)

;; ==========================================
;; 開発ツール類 (Lazy Load化)
;; ==========================================

(leaf magit
    :straight t
    :leaf-defer t
    :bind ((magit-mode-map
               ("C-n" . next-line)
               ("C-p" . previous-line)
               ("C-c C-n" . magit-section-forward)
               ("C-c C-p" . magit-section-backward))
              ("C-c g" . magit-diff-working-tree))
    :custom
    (magit-save-repository-buffers . nil)
    (magit-display-buffer-function . #'magit-display-buffer-same-window-except-diff-v1)
    (magit-refresh-status-buffer . nil)
    (magit-diff-highlight-indentation . nil)
    (magit-diff-highlight-trailing . nil)
    (magit-commit-show-diffstat . nil)
    :config
    (setq magit-git-global-arguments '("-c" "core.preloadIndex=true" "-c" "core.fscache=true" "-c" "gc.auto=0")))

(leaf lsp-mode
    :straight t
    :commands (lsp lsp-deferred)
    :init
    (add-hook 'c-mode-hook #'lsp-deferred)
    (add-hook 'c++-mode-hook #'lsp-deferred)
    (setq lsp-enable-on-type-formatting nil)
    (setq lsp-enable-indentation nil)
    (setq lsp-clients-clangd-args '("-j=4" "--background-index" "--clang-tidy" "--completion-style=detailed"))
    :config
    (define-key lsp-mode-map (kbd "M-.") #'lsp-find-definition)
    (define-key lsp-mode-map (kbd "M-,") #'lsp-find-references)
    (define-key lsp-mode-map (kbd "M-s") #'lsp-find-implementation)
    (define-key lsp-mode-map (kbd "M-t") #'lsp-find-declaration)
    (defun my/lsp-start-python ()
        (interactive)
        (require 'lsp-pyright)
        (lsp)))

(leaf company :straight t :leaf-defer t :global-minor-mode global-company-mode :custom (company-idle-delay . 0.2))
(leaf which-key :straight t :leaf-defer t :global-minor-mode which-key-mode :config (which-key-setup-side-window-right))

(leaf helm
    :straight t
    :leaf-defer t
    ;; helm-mode は completing-read/read-buffer 全体を差し替えて副作用が大きいため使わない。
    ;; 必要な Helm UI だけを明示 bind し、Dired や通常の switch-to-buffer は標準挙動のままにする。
    :bind (("M-x" . helm-M-x)
              ("C-x C-f" . helm-find-files)
              ("C-x b" . helm-buffers-list))
    :config
    (with-eval-after-load 'helm-files
        (define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
        (define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
        (define-key helm-find-files-map (kbd "C-i") 'helm-execute-persistent-action)
        (define-key helm-map (kbd "C-z") 'helm-select-action)
        (define-key helm-find-files-map (kbd "C-z") 'helm-select-action)
        (setq helm-ff-skip-boring-files t)))

(leaf treemacs-evil :straight t :leaf-defer t :after (treemacs evil))
(leaf treemacs-projectile :straight t :leaf-defer t :after (treemacs projectile))
(leaf treemacs-icons-dired :straight t :leaf-defer t :hook (dired-mode . treemacs-icons-dired-enable-once))
(leaf treemacs-magit :straight t :leaf-defer t :after (treemacs magit))
(leaf treemacs-persp :straight t :leaf-defer t :after (treemacs persp-mode) :config (treemacs-set-scope-type 'Perspectives))
(leaf treemacs-tab-bar :straight t :leaf-defer t :after (treemacs) :config (treemacs-set-scope-type 'Tabs))

(global-set-key (kbd "C-c C-r") 'indent-region)

(leaf helm-ag
    :straight t
    :leaf-defer t
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
    :straight t
    :leaf-defer t
    :global-minor-mode projectile-mode
    :config
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
    ;; 【重いため無効化】毎回のプロジェクトルート検索をやめる
    ;; (add-hook 'find-file-hook 'set-default-directory-to-project-root)
    )

(leaf helm-projectile
    :straight t
    :leaf-defer t
    :after (helm projectile)
    :config
    (helm-projectile-on)
    (setq projectile-completion-system 'helm)
    :bind
    (("C-c p h" . helm-projectile)
        ("C-c p n" . helm-projectile-grep)))

(leaf diff-hl
    :straight t
    :leaf-defer t
    :global-minor-mode global-diff-hl-mode
    :config
    (unless (display-graphic-p) (diff-hl-margin-mode 1)))

;; 【重いため無効化】保存時・バッファ切り替え時の差分更新をやめる
;; (add-hook 'after-save-hook 'diff-hl-update)
;; (add-hook 'focus-in-hook 'diff-hl-update)

;; fringe は GUI フレームでだけ有効。端末起動時の不要な設定呼び出しを避ける。
(when (display-graphic-p)
    (fringe-mode '(8 . 8)))

;; shell-popの設定 (※重複排除済)
(leaf shell-pop
    :straight t
    :leaf-defer t
    :custom
    (shell-pop-shell-type . '("eshell" "*eshell*" (lambda () (eshell))))
    :bind
    (("C-t" . shell-pop)))

;; eshell-specific settings (※重複排除済)
(add-hook 'eshell-mode-hook
    (lambda ()
        (define-key eshell-mode-map (kbd "<tab>") 'completion-at-point)))
(defun eshell/cdpjroot ()
    "Change directory to the root of the Git repository in Eshell."
    ;; Git 管理外では空文字へ cd してしまうため、終了コードを見て失敗時は何もしない。
    (let ((git-root (string-trim (shell-command-to-string "git rev-parse --show-toplevel 2>/dev/null"))))
        (if (string= git-root "")
            (message "Not inside a Git repository")
            (eshell/cd git-root))))

(defun my/eshell-disable-helm ()
    "Disable helm completion in eshell."
    (setq-local helm-mode-no-completion-in-region-in-modes '(eshell-mode)))
(add-hook 'eshell-mode-hook 'my/eshell-disable-helm)

(with-eval-after-load 'eshell
    (defun setup-eshell-aliases ()
        (eshell/alias "emacs" "find-file $1")
        (eshell/alias "m" "find-file $1")
        (eshell/alias "mc" "find-file $1"))
    (add-hook 'eshell-mode-hook 'setup-eshell-aliases))

(setq enable-local-variables t)

;; AI・ツール連携
(leaf copilot
    :if (executable-find "node")
    :straight (copilot :type git :host github :repo "zerolfx/copilot.el" :files ("*.el"))
    :commands (copilot-mode)
    :bind (("C-c M-f" . copilot-mode)
              (copilot-completion-map
                  ("<tab>" . copilot-accept-completion)
                  ("M-TAB" . copilot-accept-completion-by-word)
                  ("TAB"   . copilot-accept-completion)))
    ;; 【重いため無効化】全プログラミングファイルでの自動起動をやめる
    ;; :hook (prog-mode-hook . copilot-mode)
    :config
    (setq copilot-idle-delay 0.1))

;; ==========================================
;; Codex IDE
;; ==========================================

(leaf transient
    :straight t
    :leaf-defer t)

;; 【無効化】codex は agent-shell(ACP)へ移行。残しておくので戻すときはコメント解除。
;; (leaf codex-ide
;;     :straight (codex-ide
;;                   :type git
;;                   :host github
;;                   :repo "dgillis/emacs-codex-ide"
;;                   :files (:defaults "bin" "*.el"))
;;     :commands (codex-ide codex-ide-menu)
;;     :bind (("C-c x" . codex-ide-menu)))

(defun my/check-codex-cli ()
    "Check whether Emacs can find the Codex CLI."
    (interactive)
    (let ((codex (executable-find "codex")))
        (if codex
            (message "codex found: %s" codex)
            (message "codex not found in Emacs exec-path"))))

;; ==========================================
;; Claude Code IDE
;; ==========================================
;; Codex 用の emacs-codex-ide と対になる、Claude Code CLI 連携。
;; claude-code-ide.el は端末バックエンド (evterm) を必要とする。

;; (leaf websocket
;;     :straight t
;;     :leaf-defer t)

;; vterm: C 実装の高速端末。claude の重量級 TUI でも固まりにくい。
;; ビルドに libvterm-dev(システムライブラリ)+ cmake + gcc が必要。
;; (leaf vterm
;;     :straight t
;;     :leaf-defer t
;;     :custom (vterm-max-scrollback . 10000))

;; (leaf claude-code-ide
;;     :straight (claude-code-ide
;;                   :type git
;;                   :host github
;;                   :repo "manzaltu/claude-code-ide.el"
;;                   :files (:defaults))
;;     :commands (claude-code-ide claude-code-ide-menu)
;;     :bind (("C-c Y" . claude-code-ide-menu))
;;     :custom (claude-code-ide-terminal-backend . 'vterm)
;;     :config
;;     ;; Emacs 側のツール (ファイルを開く/差分表示など) を Claude Code に公開する。
;;     (when (fboundp 'claude-code-ide-emacs-tools-setup)
;;         (claude-code-ide-emacs-tools-setup)))

;; (defun my/check-claude-cli ()
;;     "Check whether Emacs can find the Claude Code CLI."
;;     (interactive)
;;     (let ((claude (executable-find "claude")))
;;         (if claude
;;             (message "claude found: %s" claude)
;;             (message "claude not found in Emacs exec-path"))))

;; ==========================================
;; agent-shell (ACP): Claude を「端末TUI」ではなく通常の Emacs バッファに描画。
;; ==========================================
;; codex-ide と同じ ACP 方式なので、会話をバッファのように自由に遡れる/検索できる。
;; claude-code-ide(vterm/MCP)と併設し、用途で使い分ける。
;;   - じっくり読む/遡る          → agent-shell    (M-x agent-shell-anthropic-start-claude-code)
;;   - Emacs情報を使った自律作業  → claude-code-ide (C-c Y)
;; 別途 npm ブリッジが必要:
;;   npm install -g @agentclientprotocol/claude-agent-acp

;; 依存 (acp / shell-maker) は agent-shell が自動で引き込む。
(leaf agent-shell
    :straight t
    :commands (agent-shell agent-shell-anthropic-start-claude-code agent-shell-openai-start-codex)
    :bind (("C-c y" . agent-shell-anthropic-start-claude-code)
              ("C-c x" . agent-shell-openai-start-codex))
    :config
    ;; 既存の Claude ログイン認証を利用(APIキー不要)。値は関数呼び出しのため
    ;; パッケージ読み込み後 (:config) に設定してエラーを避ける。
    (when (fboundp 'agent-shell-anthropic-make-authentication)
        (setq agent-shell-anthropic-authentication
            (agent-shell-anthropic-make-authentication :login t)))
    ;; codex も既存のログイン認証を利用。別途ブリッジ codex-acp が PATH に必要。
    (when (fboundp 'agent-shell-openai-make-authentication)
        (setq agent-shell-openai-authentication
            (agent-shell-openai-make-authentication :login t)))
    ;; resume 時に会話全体を再表示する(既定 minimal はタイトルのみで過去ログが出ない)。
    ;; 軽くしたい場合は 'first-last / 'last に変更可。
    (setq agent-shell-session-restore-verbosity 'full)
    ;; --- A案: セッション選択のときだけ helm を使う(全体の helm-mode は有効化しない) ---
    ;; agent-shell のセッション一覧ピッカー呼び出し中だけ helm-mode を一時的に有効化し、
    ;; 終わったら元へ戻す。既存の completing-read 操作感には影響しない。
    (defun my/agent-shell-with-helm (orig &rest args)
        "Run ORIG with `helm-mode' temporarily enabled for a readable list."
        (if (bound-and-true-p helm-mode)
            (apply orig args)
            (helm-mode 1)
            (unwind-protect (apply orig args)
                (helm-mode -1))))
    (dolist (fn '(agent-shell--prompt-select-session
                     agent-shell--read-shell-buffer))
        (when (fboundp fn)
            (advice-add fn :around #'my/agent-shell-with-helm))))

(leaf clang-format :straight t :leaf-defer t :bind (("C-c C-_" . clang-format-region) ("C-c /" . clang-format-buffer)))

;; --- C-c d と C-c C-d でカレントディレクトリを移動 ---
(defun my/set-cwd-to-current-file ()
    "開いているファイルの場所に cd します。"
    (interactive)
    (if (buffer-file-name)
        (let ((dir (file-name-directory (buffer-file-name)))) (cd dir) (message "Changed cwd to: %s" dir))
        (message "Not visiting a file")))
(global-set-key (kbd "C-c d") 'my/set-cwd-to-current-file)
;; Codex IDE session mode uses C-c C-d for session diff.
;;(global-set-key (kbd "C-c C-d") 'my/set-cwd-to-current-file)

(leaf markdown-mode :straight t :leaf-defer t :mode ("\\.md\\'" . markdown-mode))

(leaf org
    :straight t
    :leaf-defer t
    :mode (("\\.org\\'" . org-mode))
    :bind (("C-c a" . org-agenda)
              ("C-c l" . org-store-link)
              ("C-c c" . org-capture)
              ("C-c n c" . org-capture))
    :custom
    (org-directory . "~/Documents/org")
    (org-default-notes-file . "~/Documents/org/inbox.org")
    (org-startup-indented . t)
    (org-hide-leading-stars . t)
    (org-log-done . (quote time))
    :config
    ;; Org の既定ディレクトリが無い環境でも capture/agenda をすぐ使えるようにする。
    (make-directory org-directory t)
    (unless (file-exists-p org-default-notes-file)
        (write-region "" nil org-default-notes-file))
    (setq org-agenda-files (list org-directory))
    (setq org-capture-templates
        (quote (("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
                    "* TODO %?\n  %U\n")
                   ("n" "Note" entry (file+headline org-default-notes-file "Notes")
                       "* %?\n  %U\n")))))

(leaf denote
    :straight t
    :leaf-defer t
    :commands (denote denote-open-or-create denote-link denote-backlinks denote-dired)
    :bind (("C-c n n" . denote)
              ("C-c n o" . denote-open-or-create)
              ("C-c n l" . denote-link)
              ("C-c n b" . denote-backlinks)
              ("C-c n d" . denote-dired))
    :custom
    (denote-directory . "~/Documents/notes")
    (denote-known-keywords . (quote ("emacs" "work" "study" "idea")))
    (denote-infer-keywords . t)
    (denote-sort-keywords . t)
    :config
    ;; Denote の保存先を明示し、初回起動直後からノート作成できるようにする。
    (make-directory denote-directory t))

;; 選択範囲を tab幅ぶん右/左にずらす
(defun my/indent-shift-right (beg end)
    (interactive "r")
    (indent-rigidly beg end tab-width))
(defun my/indent-shift-left (beg end)
    (interactive "r")
    (indent-rigidly beg end (- tab-width)))
(global-set-key (kbd "C-c ]") #'my/indent-shift-right)
(global-set-key (kbd "C-c [") #'my/indent-shift-left)

;;; Emacs Lisp (.el) 用：手動整形 (C-c / , C-c C-_)
(defun my/elisp-format-region (beg end)
    (interactive "r")
    (let ((lisp-indent-offset 4))
        (save-excursion
            (indent-region beg end)
            (delete-trailing-whitespace beg end))))
(defun my/elisp-format-buffer ()
    (interactive)
    (my/elisp-format-region (point-min) (point-max)))

(add-hook 'emacs-lisp-mode-hook
    (lambda ()
        (setq-local lisp-indent-offset 4)
        (setq-local tab-width 4)
        (local-set-key (kbd "C-c /") #'my/elisp-format-buffer)
        (local-set-key (kbd "C-c C-_") #'my/elisp-format-region)
        (local-set-key (kbd "C-c C-/") #'my/elisp-format-region)))
(add-hook 'lisp-interaction-mode-hook
    (lambda ()
        (setq-local lisp-indent-offset 4)
        (setq-local tab-width 4)
        (local-set-key (kbd "C-c /") #'my/elisp-format-buffer)
        (local-set-key (kbd "C-c C-_") #'my/elisp-format-region)
        (local-set-key (kbd "C-c C-/") #'my/elisp-format-region)))

;;; Python用：Blackによる自動整形 (C-c /)
(leaf python-black
    :straight t
    :leaf-defer t
    :after python
    :config
    (add-hook 'python-mode-hook
        (lambda ()
            (local-set-key (kbd "C-c /") #'python-black-buffer)
            (local-set-key (kbd "C-c C-_") #'python-black-region))))

;;; C/C++用：カスタムコメント機能 (//ys )
(defun my-c-comment-dwim (arg)
    (interactive "*P")
    (let ((comment-start "//ys "))
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
(add-hook 'c-mode-common-hook 'my-c-comment-style)
(add-hook 'c-mode-common-hook
    (lambda ()
        (local-set-key (kbd "M-;") 'my-c-comment-dwim)))

;;; Python用：カスタムコメント機能 (#ys )
(defun my-python-comment-dwim (arg)
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


(global-set-key (kbd "<f5>") 'compile)

;; Nixファイルのサポート
(leaf nix-mode
    :straight t
    :leaf-defer t
    :mode "\\.nix\\'")

;; ==========================================
;; コードの折りたたみ (HideShow)
;; ==========================================
(leaf hideshow
    :require t
    :hook (prog-mode-hook . hs-minor-mode) ; 全てのプログラミング言語で有効化
    :bind ((prog-mode-map
               ("C-c f" . hs-toggle-hiding)   ; カーソル位置のブロックを折りたたみ/展開 (Fold)
               ("C-c F" . hs-hide-all)        ; ファイル全体のブロックをすべて折りたたみ
               ("C-c A" . hs-show-all))))     ; ファイル全体のブロックをすべて展開 (All)

;; ==========================================
;; 時間表示
;; ==========================================
(defvar my/header-line-clock-timer nil)

(defun my/date-time-string ()
    (format-time-string "%Y-%m-%d %H:%M"))

(setq global-mode-string
      (delq 'display-time-string global-mode-string))
(display-time-mode -1)

(defun my/tab-bar-date-time ()
    (concat " " (my/date-time-string) " "))

(setq tab-bar-format '(my/tab-bar-date-time))
(tab-bar-mode 1)

(when (timerp my/header-line-clock-timer)
    (cancel-timer my/header-line-clock-timer))
(setq my/header-line-clock-timer
      (run-at-time t 60 #'force-mode-line-update t))
