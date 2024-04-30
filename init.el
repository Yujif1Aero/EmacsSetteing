;;;;
;; package management
;;https://qiita.com/namn1125/items/5cd6a9cbbf17fb85c740#packageel-%E3%82%92%E7%9B%B4%E6%8E%A5%E5%88%A9%E7%94%A8%E3%81%97%E3%81%AA%E3%81%84%E7%90%86%E7%94%B1%E3%81%A8gitgithub%E3%81%AB%E3%82%88%E3%82%8B-initel-%E3%81%AE%E7%AE%A1%E7%90%86
;;Backtrace バッファが表示されないようにするに
(setq debug-on-error nil)
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

(defun namn/add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
	     (expand-file-name (concat user-emacs-directory path))))
	(unless (file-exists-p default-directory)
	  (make-directory default-directory))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

(namn/add-to-load-path "elisp" "conf")

;; Emacs自体が書き込む設定先の変更
(setq custom-file (locate-user-emacs-file "custom.el"))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

(prog1 "prepare leaf"
  (prog1 "package"
    (custom-set-variables
     '(package-archives '(("org"   . "http://orgmode.org/elpa/")
			  ("melpa" . "http://melpa.org/packages/")
			  ("gnu"   . "http://elpa.gnu.org/packages/"))))
    (package-initialize))

  (prog1 "leaf"
    (unless (package-installed-p 'leaf)
      (unless (assoc 'leaf package-archive-contents)
	(package-refresh-contents))
      (condition-case err
	  (package-install 'leaf)
	(error
	 (package-refresh-contents)       ; renew local melpa cache if fail
	 (package-install 'leaf))))

    (leaf leaf-keywords
      :ensure t
      :config (leaf-keywords-init)))

  (prog1 "optional packages for leaf-keywords"
    ;; optional packages if you want to use :hydra, :el-get,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t
      :custom ((el-get-git-shallow-clone  . t)))))


;;;emacs seting;
(add-to-list 'default-frame-alist '(cursor-type . bar))
;; 現在開いている各フレームに対してカーソル形状を適用
(dolist (frame (frame-list))
  (modify-frame-parameters frame '((cursor-type . bar))))
(electric-pair-mode 1)
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(global-set-key "\C-x\C-b" 'buffer-menu)
;;次のwindowに移動

(define-key global-map (kbd "C-c o")'other-window)
;(define-key global-map (kbd "C-i")'other-window)

;;コードを折りたたむ
(leaf *truncate-lines
  :bind ("M-z" . toggle-truncate-lines))

;; キーワードのカラー表示を有効化
(global-font-lock-mode t)



;; 行間
(setq-default line-spacing 0)


					; in the current buffer,
(hl-line-mode) ; enable or disable highlight cursor line
(hl-line-mode t) ; enable highlight cursor line
(hl-line-mode nil) ; disable highlight cursor line


;;(set-face-background 'region "SkyBlue")
;;(set-face-background 'region "#E0DFDB")



;;(show-paren-mode 1)
(show-paren-mode t)
(setq its-hira-period "．")
(setq its-hira-comma "，")
(defun replace-kv-region (l)
  (save-excursion
    (save-restriction
      (narrow-to-region b e)
      (format-replace-strings l)
      ))
  )
					;
(defun query-replace-strings (a)
  (dolist (i a)
    (goto-char b)
    (query-replace (car i) (cdr i))
    )
  )
(defun query-replace-kv-region (l)
  (save-excursion
    (save-restriction
      (narrow-to-region b e)
      (query-replace-strings l)
      ))
  )
                                        ;
(show-paren-mode 1)

;;日本語の設定
;;https://utsuboiwa.blogspot.com/2014/07/sunnyside-emacs.html

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)

(set-language-environment "Japanese")


(leaf mozc
  :if (executable-find "mozc_emacs_helper")
  :config
  (setq default-input-method "japanese-mozc"
	mozc-candidate-style 'overlay)
  :bind (("C-\\" . mozc-mode)))



(defconst kutoten-zenpunct-kv '(("。" . "．") ("、" . "，")))
(defconst zenpunct-kutoten-kv '(("．" . "。") ("，" . "、")))
(defconst zenpunct-hanpunct-kv '(("．" . ". ") ("，" . ", ") ("。" . "｡ ") ("、" . "､ ")))
(defconst hanpunct-zenpunct-kv '((". " . "．") (", " . "，") ("｡ " . "。") ("､ " . "、")))
					;
(defun replace-kutoten-zenpunct-region (b e)
  (interactive "r")
  (replace-kv-region kutoten-zenpunct-kv))
(defun replace-zenpunct-kutoten-region (b e)
  (interactive "r")
  (replace-kv-region zenpunct-kutoten-kv))
(defun replace-zenpunct-hanpunct-region (b e)
  (interactive "r")
  (replace-kv-region zenpunct-hanpunct-kv))
(defun replace-hanpunct-zenpunct-region (b e)
  (interactive "r")
  (replace-kv-region hanpunct-zenpunct-kv))
					;
(defun query-replace-kutoten-zenpunct-region (b e)
  (interactive "r")
  (query-replace-kv-region kutoten-zenpunct-kv))
(defun query-replace-zenpunct-kutoten-region (b e)
  (interactive "r")
  (query-replace-kv-region zenpunct-kutoten-kv))
(defun query-replace-zenpunct-hanpunct-region (b e)
  (interactive "r")
  (query-replace-kv-region zenpunct-hanpunct-kv))
(defun query-replace-hanpunct-zenpunct-region (b e)
  (interactive "r")
  (query-replace-kv-region hanpunct-zenpunct-kv))
					;
(global-set-key "\C-x\C-m/" 'replace-kutoten-zenpunct-region)
(global-set-key "\C-x\C-m?" 'replace-zenpunct-kutoten-region)
(global-set-key "\C-x\C-m." 'replace-zenpunct-hanpunct-region)
(global-set-key "\C-x\C-m," 'replace-hanpunct-zenpunct-region)
					;
(global-set-key "\C-x\C-m\M-/" 'query-replace-kutoten-zenpunct-region)
(global-set-key "\C-x\C-m\M-?" 'query-replace-zenpunct-kutoten-region)
(global-set-key "\C-x\C-m\M-." 'query-replace-zenpunct-hanpunct-region)
(global-set-key "\C-x\C-m\M-," 'query-replace-hanpunct-zenpunct-region)



;;---------emacs でコピーしたものを他のアプリでも使用可能にする
;;; Copy and Paste parameters
;;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Clipboard.html
					;(setq interprogram-cut-function nil)
					;(setq interprogram-paste-function nil)

;; old linux
;; (setq x-select-enable-clipboard nil)
;; (setq save-interprogram-paste-before-kill nil)
;; (setq yank-pop-change-selection nil)
;; (setq x-select-enable-clipboard-manager nil)
;; (setq x-select-enable-primary t)
;; (setq mouse-drag-copy-region t
;; ;; Key binding
;; (global-set-key [f5] 'clipboard-kill-region)
;; (global-set-key [f6] 'clipboard-kill-ring-save)
;; (global-set-key [f7] 'clipboard-yank)

;;for linux
					;(setq select-enable-primary nil)
;; (setq x-select-enable-clipboard t)
;; (leaf xclip
;;   :ensure t
;;   :config
;;   ;; xclip-mode を有効にする
;;   (xclip-mode 1))

;; ;; for windows
;; (cond (window-system
;;        (setq x-select-enable-clipboard t)
;;        ))


;; ;; for linux(wsl) new
;; ;; sync with x clipboard
(unless window-system
  (when (getenv "DISPLAY")
    ;; Callback for when user cuts
    (defun xsel-cut-function (text &optional push)
      ;; Insert text to temp-buffer, and "send" content to xsel stdin
      (with-temp-buffer
        (insert text)
        ;; I prefer using the "clipboard" selection (the one the
        ;; typically is used by c-c/c-v) before the primary selection
        ;; (that uses mouse-select/middle-button-click)
        (call-process-region (point-min) (point-max) "xsel" nil 0 nil "--clipboard" "--input")))
    ;; Call back for when user pastes
    (defun xsel-paste-function()
      ;; Find out what is current selection by xsel. If it is different
      ;; from the top of the kill-ring (car kill-ring), then return
      ;; it. Else, nil is returned, so whatever is in the top of the
      ;; kill-ring will be used.
      (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))
        (unless (string= (car kill-ring) xsel-output)
          xsel-output )))
    ;; Attach callbacks to hooks
    (setq interprogram-cut-function 'xsel-cut-function)
    (setq interprogram-paste-function 'xsel-paste-function)
    ;; Idea from
    ;; http://shreevatsa.wordpress.com/2006/10/22/emacs-copypaste-and-x/
    ;; http://www.mail-archive.com/help-gnu-emacs@gnu.org/msg03577.html
    ))


;;editer colour
(setq auto-mode-alist (cons '("\\.cu$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cuh$" . c++-mode) auto-mode-alist))
(leaf nix-mode
  :ensure t
  :mode "\\.nix\\'")


(require 'flymake)
(defun flymake-get-make-cmdline (source base-dir)
  (list "make"
	(list "-s" "-C"
	      base-dir
	      (concat "CHK_SOURCES=" source)
	      "SYNTAX_CHECK_MODE=1")))

;; (when (require 'package nil t)
;;   (add-to-list 'package-archives
;;     '("melpa-stable" . "https://stable.melpa.org/packages/"))
;;   (package-initialize))


;; xterm のマウスイベントを取得する
(xterm-mouse-mode t)
;; マウスホイールを取得する
(mouse-wheel-mode t)



;; cmdキーを superとして割り当てる
					;(setq mac-command-modifier 'super)
;; バックスペースの設定
;(global-set-key (kbd "C-h") 'delete-backward-char)


					;redo
(leaf undo-tree
  :ensure t
  :leaf-defer nil
  :bind (("M-/" . undo-tree-redo))
  :custom ((global-undo-tree-mode . t)))
(setq undo-no-redo t) ; 過去のundoがredoされないようにする
(setq undo-limit 600000)
(setq undo-strong-limit 900000)

					;tab 可視化
(leaf whitespace
  :ensure t
  :custom
  ((whitespace-style . '(face
			 trailing
			 tabs
			 ;; spaces
			 ;; empty
			 space-mark
			 tab-mark))
   (whitespace-display-mappings . '((tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
   (global-whitespace-mode . t)))

;;tabを使えないようにする
					;(setq-default indent-tabs-mode nil)
;;tabをスペース4つに
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(global-set-key (kbd "TAB") 'tab-to-tab-stop)

					;見た目:https://qiita.com/blue0513/items/ff8b5822701aeb2e9aae

;; font
;;(add-to-list 'default-frame-alist '(font . "ricty-12"))

;; color theme
(leaf monokai-theme
  :ensure t
  :config
  (load-theme 'monokai t))


;; alpha
(if window-system
    (progn
      (set-frame-parameter nil 'alpha 95)))

;; ;; 非アクティブウィンドウの背景色を設定
;; (leaf hiwin
;;   :ensure t
;;   :config
;;   (hiwin-activate))
;; (set-face-background 'hiwin-face "gray30")

;; line numberの表示
(leaf display-line-numbers
  :config
  (global-display-line-numbers-mode t))


;; メニューバーを非表示
(menu-bar-mode 0)

;; ツールバーを非表示
(tool-bar-mode 0)

;; default scroll bar消去
(scroll-bar-mode -1)

;; 現在ポイントがある関数名をモードラインに表示
(which-function-mode 1)

;; 対応する括弧をハイライト
(show-paren-mode 1)

;; リージョンのハイライト
(transient-mark-mode 1)

;; タイトルにフルパス表示
(setq frame-title-format "%f")

;;current directory 表示
(let ((ls (member 'mode-line-buffer-identification
		  mode-line-format)))
  (setcdr ls
	  (cons '(:eval (concat " ("
				(abbreviate-file-name default-directory)
				")"))
		(cdr ls))))

;;;TabやSidebarのカスタム
;; elscreen（上部タブ）
;;; Package Management with leaf
;; `leaf` は Emacs の設定を簡潔にし、パッケージの遅延ロードや設定の明示性を向上させるマクロを提供します。
;; 以下では、`elscreen` と `neotree` のインストールと設定を `leaf` を使って行います。

;; elscreen の設定
(leaf elscreen
  :ensure t  ; elscreen パッケージがインストールされていなければ自動的にインストールします。
  :init
  ;; elscreen を起動します。これによりタブ機能が有効になります。
  (elscreen-start)
  :bind
  ;; キーバインドの設定: タブの作成、次/前のタブへの移動、現在のタブの削除を行います。
  (( "C-M-t" . elscreen-create)  ; 新しいタブを作成します。
   ("C-M-l" . elscreen-next)    ; 次のタブに移動します。
   ("C-M-r" . elscreen-previous)  ; 前のタブに移動します。
   ( "C-M-c" . elscreen-kill))  ; 現在のタブを閉じます。

  :config
  ;; タブ表示のカスタマイズ
  ;; タブの[X]ボタンと[<->]ボタンを非表示にします。
  (setq elscreen-tab-display-kill-screen nil
	elscreen-tab-display-control nil)
  ;; タブの見た目（背景色、前景色）を設定します。
  (set-face-attribute 'elscreen-tab-background-face nil
		      :background "grey10"
		      :foreground "grey90")
  (set-face-attribute 'elscreen-tab-control-face nil
		      :background "grey20"
		      :foreground "grey90")
  (set-face-attribute 'elscreen-tab-current-screen-face nil
		      :background "grey20"
		      :foreground "grey90")
  (set-face-attribute 'elscreen-tab-other-screen-face nil
		      :background "grey30"
		      :foreground "grey60")
  ;; タブに表示する内容（バッファ名やモード名）をカスタマイズします。
  (setq elscreen-buffer-to-nickname-alist
	'(("^dired-mode$" .
	   (lambda ()
	     (format "Dired(%s)" dired-directory)))
	  ("^Info-mode$" .
	   (lambda ()
	     (format "Info(%s)" (file-name-nondirectory Info-current-file))))
	  ("^mew-draft-mode$" .
	   (lambda ()
	     (format "Mew(%s)" (buffer-name (current-buffer)))))
	  ("^mew-" . "Mew")
	  ("^irchat-" . "IRChat")
	  ("^liece-" . "Liece")
	  ("^lookup-" . "Lookup"))
	elscreen-mode-to-nickname-alist
	'(("[Ss]hell" . "shell")
	  ("compilation" . "compile")
	  ("-telnet" . "telnet")
	  ("dict" . "OnlineDict")
	  ("*WL:Message*" . "Wanderlust"))))

;; neotree の設定
(leaf neotree
  :ensure t  ; neotree パッケージがインストールされていなければ自動的にインストールします。
  :bind
  ;; キーバインドの設定: neotree ウィンドウの表示/非表示を切り替えます。
  ("\C-c \C-t" . neotree-toggle))


;;操作性の向上

;; スクロールは1行ごとに
;;(setq mouse-wheel-scroll-amount '(1 ((shift) . 5)))

;; スクロールの加速をやめる
;;(setq mouse-wheel-progressive-speed nil)


;; bufferの最後でカーソルを動かそうとしても音をならなくする
(defun next-line (arg)
  (interactive "p")
  (condition-case nil
      (line-move arg)
    (end-of-buffer)))

;; エラー音をならなくする
(setq ring-bell-function 'ignore)


;; ;;windowの操作
;; ;; golden ratio
;; (golden-ratio-mode 1)
;; (add-to-list 'golden-ratio-exclude-buffer-names " *NeoTree*")

;; active window move
(global-set-key (kbd "<C-left>")  'windmove-left)
(global-set-key (kbd "<C-down>")  'windmove-down)
(global-set-key (kbd "<C-up>")    'windmove-up)
(global-set-key (kbd "<C-right>") 'windmove-right)

;;grep improvement
;; 大文字・小文字を区別しない
(setq case-fold-search t)

;; ファイル名検索
(define-key global-map (kbd "C-c i")  'find-name-dired)

;; ファイル内検索（いらないメッセージは消去）
(define-key global-map (kbd "C-c f") 'rgrep)
;; rgrepのheader messageを消去
(defun delete-grep-header ()
  (save-excursion
    (with-current-buffer grep-last-buffer
      (forward-line 5)
      (narrow-to-region (point) (point-max)))))
(defadvice grep (after delete-grep-header activate) (delete-grep-header))
(defadvice rgrep (after delete-grep-header activate) (delete-grep-header))

;; rgrep時などに，新規にwindowを立ち上げる
					;(setq display-buffer-alist '("*Help*" "*compilation*" "*interpretation*" "*grep*" ))
(setq display-buffer-alist
      '(("\\*Help\\*" display-buffer-pop-up-window)
	("\\*compilation\\*" display-buffer-pop-up-window)
	("\\*interpretation\\*" display-buffer-pop-up-window)
	("\\*grep\\*" display-buffer-pop-up-window)))

;; "grepバッファに切り替える"
(defun my-switch-grep-buffer()
  (interactive)
  (if (get-buffer "*grep*")
      (pop-to-buffer "*grep*")
    (message "No grep buffer")))
(global-set-key (kbd "C-c e") 'my-switch-grep-buffer)

;; eshelの設定
(leaf eshell-git-prompt
  :ensure t
  :config
  (eshell-git-prompt-use-theme 'git-radar))



;; eshell or term
(leaf shell-pop
  :ensure t
  :require t
  :custom
  ;; shell-popで使用するシェルのタイプを設定します。ここではeshellを使用します。

   (shell-pop-shell-type . '("eshell" "*eshell*" (lambda () (eshell))))
  ;;   (shell-pop-shell-type . '("term" "*term*" (lambda () (term "/run/current-system/sw/bin/zsh"))))
  ;;   (shell-pop-shell-type . '("term" "*term*" (lambda () (term "/bin/bash"))))


  ;; 例: (shell-pop-window-size . 30) ; ウィンドウのサイズを30%に設定
  ;;     (shell-pop-full-span . t) ; フル幅で表示
  :bind
  ;; 特定のキーバインド（ここでは C-t ）をshell-popのトグル関数にバインドします。
  (("C-t" . shell-pop)))



;; ;;auto-complete -> LSPが同じ機能を持っている
;; (leaf auto-complete
;;   :ensure t
;;   :leaf-defer nil
;;   :config
;;   (ac-config-default)
;;   :custom ((ac-use-menu-map . t)
;; 	   (ac-ignore-case . nil))
;;   :bind (:ac-mode-map
;; 					; ("M-TAB" . auto-complete))
;; 	 ("M-p" . auto-complete)))


;; 履歴参照
(leaf recentf
  :config
  (setq recentf-save-file "~/.emacs.d/.recentf"
	recentf-max-saved-items 1000
	recentf-exclude '(".recentf")
	recentf-auto-cleanup 'never)
  (recentf-mode 1)
  (run-with-idle-timer 30 t
		       (lambda ()
			 (let ((message-log-max nil))
			   (with-temp-message ""
			     (recentf-save-list)))))
  :bind (("C-c h" . recentf-open-files)))


;; コメントアウト
;; 選択範囲
;;(global-set-key (kbd "s-;") 'comment-region)

;; コメントアウト
;; 一行
;; (defun one-line-comment ()
;;   (interactive)
;;   (save-excursion
;;     (beginning-of-line)
;;     (set-mark (point))
;;     (end-of-line)
;;     (comment-or-uncomment-region (region-beginning) (region-end))))
;;(global-set-key (kbd "s-/") 'one-line-comment)

;; 直前のバッファに戻る
					;(global-set-key (kbd "M-[") 'switch-to-prev-buffer)
(global-set-key (kbd "C-M-[") 'previous-buffer)

;; 次のバッファに進む
					;(global-set-key (kbd "M-]") 'switch-to-next-buffer)
(global-set-key (kbd "C-M-]") 'next-buffer)

;; ;; ;;GIT
(leaf git-gutter
  :ensure t
  :global-minor-mode global-git-gutter-mode)
(leaf magit
  :ensure t
  :bind ((magit-mode-map
	  ("C-c n" . magit-section-forward)
	  ("C-c p" . magit-section-backward))
	 ("C-c C-g" . magit-diff-working-tree)))


;;;ファイルの自動再読み込み（Auto Revert）
(leaf autorevert
  :config


    (global-auto-revert-mode 1))


;;goto-line
(global-set-key (kbd "C-x C-g") 'goto-line)




;; eshell からファイルを開く.
(with-eval-after-load 'eshell
  (defun setup-eshell-aliases ()
    (eshell/alias "emacs" "find-file $1")
    (eshell/alias "m" "find-file $1")
    (eshell/alias "mc" "find-file $1"))
  (add-hook 'eshell-mode-hook 'setup-eshell-aliases))



;; gnu-global->LSPに比べると精度が良くない
;; (leaf ggtags
;;   :ensure t  ;; gnu-global パッケージを自動でインストール
;;   :hook (c-mode-common-hook) ;; Hook を利用して自動的に ggtags-mode を有効に
;;   :init
;;   ;; gtags-mode がロードされた後で設定を行う
;;   (with-eval-after-load 'ggtags
;;     ;; キーバインドの設定
;;     (define-key ggtags-mode-map (kbd "M-.") 'ggtags-find-tag)
;;     (define-key ggtags-mode-map (kbd "M-,") 'ggtags-find-rtag)))
;; (leaf ggtags
;;   :ensure t  ;; gnu-global パッケージを自動でインストール
;;   :hook (c-mode-common-hook) ;; Hook を利用して自動的に ggtags-mode を有効に
;;   :init
;;   ;; gtags-mode がロードされた後で設定を行う
;;   (with-eval-after-load 'ggtags
;;     ;; ラッパー関数の定義
;;     (defun my-ggtags-find-tag ()
;;       "Find the tag at point using `ggtags-find-tag'."
;;       (interactive)
;;       (let ((tag (thing-at-point 'symbol)))
;;         (if tag
;;             (ggtags-find-tag tag)
;;           (message "No tag found at point!"))))
    
;;     (defun my-ggtags-find-rtag ()
;;       "Find the reference tag at point using `ggtags-find-rtag'."
;;       (interactive)
;;       (let ((tag (thing-at-point 'symbol)))
;;         (if tag
;;             (ggtags-find-rtag tag)
;;           (message "No reference tag found at point!"))))
    
;;     ;; キーバインドの設定
;;     (define-key ggtags-mode-map (kbd "M-.") 'my-ggtags-find-tag)
;;     (define-key ggtags-mode-map (kbd "M-,") 'my-ggtags-find-rtag)))

;; (autoload 'gtags-mode "gtags" "" t)
;; (setq gtags-mode-hook
;;       '(lambda ()
;;          (local-set-key "\M-." 'gtags-find-tag)
;;          (local-set-key "\M-," 'gtags-find-rtag)
;;          (local-set-key "\M-s" 'gtags-find-symbol)
;;          (local-set-key "\M-t" 'gtags-pop-stack)
;;          ))
;; (add-hook 'c-mode-common-hook
;;           '(lambda()
;;              (gtags-mode 1)
;;              (gtags-make-complete-list)
;;              ))


;; ;; LSPモードの設定とキーバインドの調整(ref ::https://qiita.com/kari_tech/items/4754fac39504dccfd7be ) LSPの代わりにeglotを使用
;; (leaf lsp-mode
;;   :ensure t
;;   :commands lsp
;;   :hook ((c-mode-hook c++-mode-hook python-mode-hook) . lsp)
;;   :init
;;   (setq lsp-prefer-flymake nil)  ;; FlymakeではなくFlycheckを使用
;; ;;  (setq lsp-clients-clangd-args '("--header-insertion=never"))
;;   :config
;;   ;; キーバインドをGTAGSからLSPに再割り当て
;;   (define-key lsp-mode-map (kbd "M-.") #'lsp-find-definition)
;;   (define-key lsp-mode-map (kbd "M-,") #'lsp-find-references)
;;   (define-key lsp-mode-map (kbd "M-s") #'lsp-ui-sideline-mode)
;;   (define-key lsp-mode-map (kbd "M-t") #'lsp-ui-peek-jump-backward))

;; ;; lsp-pyright の設定
;; (leaf lsp-pyright
;;   :ensure t
;;   :after lsp-mode
;;   :hook (python-mode-hook . (lambda ()
;;                               (require 'lsp-pyright)
;;                               (lsp))))  ;; Pythonファイルで自動的にlspを起動

;; ;; LSP UIの追加設定
;; (leaf lsp-ui
;;   :ensure t
;;   :commands lsp-ui-mode
;;   :config
;;   (setq lsp-ui-doc-enable t
;;         lsp-ui-doc-use-childframe t
;;         lsp-ui-doc-position 'top
;;         lsp-ui-doc-include-signature t
;;         lsp-ui-sideline-enable nil
;;         lsp-ui-flycheck-enable t
;;         lsp-ui-flycheck-list-position 'right
;;         lsp-ui-flycheck-live-reporting t
;;         lsp-ui-peek-enable t
;;         lsp-ui-peek-list-width 60
;;         lsp-ui-peek-peek-height 25))

;;eglot(https://github.com/joaotavora/eglot)(https://rn.nyaomin.info/entry/2024/01/16/224657)LSPの簡略版だがうまくつかえない
(leaf eglot
      :ensure t
      :config
      (add-to-list 'eglot-server-programs '((c-mode c++-mode python-mode js-mode js-ts-mode typescript-mode typescript-ts-mode) . (eglot-deno "deno" "lsp")))
      (defclass eglot-deno (eglot-lsp-server) () :documentation "A custom class for deno lsp.")
      (cl-defmethod eglot-initialization-options ((server eglot-deno))
        "Passes through required deno initialization options"
        (list :enable t :lint t))
     ;; (setq eglot-ignored-server-capabilities '(:documentHighlightProvider :inlayHintProvider))
      (setq eldoc-echo-area-use-multiline-p nil)
      :hook
      ((sh-mode
        c-mode
        c++-mode
        python-mode
        ruby-mode
        rust-mode
        html-mode
        css-mode
        js-mode
        ) . eglot-ensure)
      )

;; companyの設定
(leaf company
  :ensure t
  :init
  ;;(global-company-mode)
   :hook ((c-mode-hook c++-mode-hook python-mode-hook) . company-mode)
  :config
  (setq company-idle-delay 0.0)  ;; 自動補完の遅延なし
  (setq company-minimum-prefix-length 1))  ;; 1文字入力されたら補完を開始

;; flycheckの設定
(leaf flycheck
  :ensure t
  :init
  (global-flycheck-mode))

;; Ediffのハイライト色を設定
(custom-set-faces
 '(ediff-current-diff-A ((t (:background "#1c1c1c" :foreground "#ffffff"))))
 '(ediff-current-diff-B ((t (:background "#1c1c1c" :foreground "#ffffff"))))
 '(ediff-current-diff-C ((t (:background "#1c1c1c" :foreground "#ffffff"))))
 '(ediff-even-diff-A ((t (:background "#262626"))))
 '(ediff-even-diff-B ((t (:background "#262626"))))
 '(ediff-even-diff-C ((t (:background "#262626"))))
 '(ediff-odd-diff-A ((t (:background "#262626"))))
 '(ediff-odd-diff-B ((t (:background "#262626"))))
 '(ediff-odd-diff-C ((t (:background "#262626")))))



;; 署名検証を無効にする
;;(setq package-check-signature nil)
;;(require 'gnu-elpa-keyring-update)
