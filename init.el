;;;;
;; package management
;;https://qiita.com/namn1125/items/5cd6a9cbbf17fb85c740#packageel-%E3%82%92%E7%9B%B4%E6%8E%A5%E5%88%A9%E7%94%A8%E3%81%97%E3%81%AA%E3%81%84%E7%90%86%E7%94%B1%E3%81%A8gitgithub%E3%81%AB%E3%82%88%E3%82%8B-initel-%E3%81%AE%E7%AE%A1%E7%90%86
;;Backtrace バッファが表示されないようにするに
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

;; Package setup
(require 'package)
(setq package-archives
      '(("org"   . "http://orgmode.org/elpa/")
        ("melpa" . "http://melpa.org/packages/")
        ("gnu"   . "http://elpa.gnu.org/packages/")))

(unless (bound-and-true-p package--initialized)
  (package-initialize))

(unless package-archive-contents
  (package-refresh-contents))

;; Install leaf if needed
(unless (package-installed-p 'leaf)
  (package-install 'leaf))

;; straight.elのブートストラップ
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

;; Load leaf
(require 'leaf)

;; Leaf setup
(leaf leaf-keywords
  :ensure t
  :config
  (leaf-keywords-init))

;; Optional packages for leaf-keywords
(leaf hydra :ensure t)
(leaf el-get
  :ensure t
  :custom
  '((el-get-git-shallow-clone . t)))

;; Use-package setup
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;;;; パッケージの遅延読み込み方法例
;; ;; Use-package の設定例
;; (use-package example-package
;;   :ensure t
;;   :defer t)

;; ;; leafの設定例
;; (leaf some-package
;;   :ensure t
;;   :hook (some-mode . some-package-function)  ;; 特定のモードが起動した時にロード
;;   :commands (some-command))                  ;; 特定のコマンドが呼ばれた時にロード



;;;emacs seting;
;;(add-to-list 'default-frame-alist '(cursor-type . bar))
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

;;for linux
;; ;;(setq select-enable-primary nil)
;; (setq x-select-enable-clipboard t)
;; (leaf xclip
;;   :ensure t
;;   :config
;;   ;; xclip-mode を有効にする
;;   (xclip-mode 1))


;; This is old version
;;; Copy and Paste parameters
;;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Clipboard.html
;; (setq interprogram-cut-function nil)
;; (setq interprogram-paste-function nil)
;; (setq x-select-enable-clipboard nil)
;; (setq save-interprogram-paste-before-kill nil)
;; (setq yank-pop-change-selection nil)
;; (setq x-select-enable-clipboard-manager nil)
;; (setq x-select-enable-primary t)
;; (setq mouse-drag-copy-region t)

;; ;; Key binding
;; (global-set-key [f5] 'clipboard-kill-region)
;; (global-set-key [f6] 'clipboard-kill-ring-save)
;; (global-set-key [f7] 'clipboard-yank)


;; for linux sever ;;sync with x clipboard(https://blog.misosi.ru/2017/01/17/osc52e-el/)
(el-get-bundle gist:49eabc1978fe3d6dedb3ca5674a16ece:osc52e)
(require 'osc52e)
(osc52-set-cut-function)

(custom-set-variables '(osc52-multiplexer 'tmux))
;; (custom-set-variables '(osc52-multiplexer 'screen)) ;; screenを使っている場合はこっち
(setq osc52-max-length 1000000)
;; osc52e自体はリージョンを送る関数は提供していないので、自分で定義する
(defun osc52-send-region-to-clipboard (start end)
  "Copy the region to the system clipboard using the OSC 52 escape sequence."
  (interactive "r")
  (let* ((text (buffer-substring-no-properties start end))
         (encoded-text (base64-encode-string (encode-coding-string text 'utf-8)))
         (osc52-escape-sequence (concat "\e]52;c;" encoded-text "\07")))
    (if (<= (length osc52-escape-sequence) osc52-max-length)
        (send-string-to-terminal osc52-escape-sequence)
      (error "Selection too long to send via OSC 52"))))


;; (defun osc52-paste-from-clipboard ()
;;   "Paste from clipboard using OSC52 protocol."
;;   (interactive)
;;   (let* ((selection (with-temp-buffer
;;                       (clipboard-yank)
;;                       (buffer-string))))
;;     (if (string-empty-p selection)
;;         (error "Clipboard is empty or not a string")
;;       (let* ((encoded-text (base64-encode-string (encode-coding-string selection 'utf-8)))
;;              (osc52-escape-sequence (concat "\e]52;c;" encoded-text "\07")))
;;         (if (<= (length osc52-escape-sequence) osc52-max-length)
;;             (send-string-to-terminal osc52-escape-sequence)
;;           (error "Selection too long to send via OSC 52"))))))



;; 適当にバインドする
;;(global-set-key (kbd "C-x M-w") 'osc52-send-region-to-clipboard)
(global-set-key (kbd "C-c M-w") 'osc52-send-region-to-clipboard)






;; for linux sever ;;sync with x clipboard(if client has no X sever )
;; (defun shared-yank ()
;;   "yank from shared kill ring file"
;;   (interactive)
;;   (with-temp-buffer
;;     (insert-file-contents "~/.tmp/shared_kill_ring")
;;     (setq shared_kill_ring (read (buffer-string))))
;;   (insert-before-markers (format "%s" shared_kill_ring)))
;; (global-set-key "\M-u" 'shared-yank)

;; (defun shared-kill (beg end)
;;   "kill to shared kill ring file"
;;   (interactive "r")
;;   (if (and mark-active transient-mark-mode)
;;       (progn
;;         (setq temp (buffer-substring beg end))
;;         (with-temp-buffer
;;           (insert (format "%s" temp))
;;           (write-file "~/.tmp/shared_kill_ring")))))
;; (global-set-key "\M-j" 'shared-kill)



;; ;; for windows
;; (cond (window-system
;;        (setq x-select-enable-clipboard t)
;;        ))


;; ;; for linux(wsl) new
;; ;; sync with x clipboard
;; (unless window-system
;;   (when (getenv "DISPLAY")
;;     ;; Callback for when user cuts
;;     (defun xsel-cut-function (text &optional push)
;;       ;; Insert text to temp-buffer, and "send" content to xsel stdin
;;       (with-temp-buffer
;;         (insert text)
;;         ;; I prefer using the "clipboard" selection (the one the
;;         ;; typically is used by c-c/c-v) before the primary selection
;;         ;; (that uses mouse-select/middle-button-click)
;;         (call-process-region (point-min) (point-max) "xsel" nil 0 nil "--clipboard" "--input")))
;;     ;; Call back for when user pastes
;;     (defun xsel-paste-function()
;;       ;; Find out what is current selection by xsel. If it is different
;;       ;; from the top of the kill-ring (car kill-ring), then return
;;       ;; it. Else, nil is returned, so whatever is in the top of the
;;       ;; kill-ring will be used.
;;       (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))
;;         (unless (string= (car kill-ring) xsel-output)
;;           xsel-output )))
;;     ;; Attach callbacks to hooks
;;     (setq interprogram-cut-function 'xsel-cut-function)
;;     (setq interprogram-paste-function 'xsel-paste-function)
;;     ;; Idea from
;;     ;; http://shreevatsa.wordpress.com/2006/10/22/emacs-copypaste-and-x/
;;     ;; http://www.mail-archive.com/help-gnu-emacs@gnu.org/msg03577.html
;;     ))


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


;;;;;;;;;;;;;;;package の設定終わり;;;;;;;;;;;;;;;;;;;


;; elscreen の設定
(leaf elscreen
  :ensure t  ; elscreen パッケージがインストールされていなければ自動的にインストールします。
  :init
  (setq elscreen-prefix-key (kbd "C-M-z"))
  ;; elscreen を起動します。これによりタブ機能が有効になります。
  (setq elscreen-prefix-key (kbd "C-M-z"))
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

;; ;; neotree の設定 ;;treeemacs  へ変更使える 
;; (leaf neotree
;;   :ensure t  ; neotree パッケージがインストールされていなければ自動的にインストールします。
;;   :bind
;;   ;; キーバインドの設定: neotree ウィンドウの表示/非表示を切り替えます。
;;   ("\C-c \C-t" . neotree-toggle))


;;操作性の向上
;; xterm-mouse-mode を有効にする
(xterm-mouse-mode 1)
;; xterm-mouse-mode をトグルする関数
(defun toggle-xterm-mouse-mode ()
  (interactive)
  (if xterm-mouse-mode
      (progn
        (xterm-mouse-mode -1)
        (message "xterm-mouse-mode disabled"))
    (progn
      (xterm-mouse-mode 1)
      (message "xterm-mouse-mode enabled"))))

;; キーバインドの設定（Ctrl + Alt + m にトグルを割り当て）
(global-set-key (kbd "C-M-m") 'toggle-xterm-mouse-mode)

;; 他のマウス設定
(mouse-wheel-mode 1)

;; マウスホイールのスクロール設定
(setq mouse-wheel-scroll-amount '(10 ((Alt) . 1)))  ;; 通常は3行、Shiftキーを押しながらは1行
(setq mouse-wheel-progressive-speed nil)  ;; スクロール速度を固定
(setq mouse-wheel-follow-mouse 't)  ;; マウスポインタの位置に従ってスクロール

;; Smooth Scroll のオプション設定
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)
;; スクロールの加速
;;(setq mouse-wheel-progressive-speed t)

;; bufferの最後でカーソルを動かそうとしても音をならなくする
(defun next-line (arg)
  (interactive "p")
  (condition-case nil
      (line-move arg)
    (end-of-buffer)))

;; エラー音をならなくする
(setq ring-bell-function 'ignore)


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
(define-key global-map (kbd "C-c C-f") 'rgrep)
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
	  ("C-c C-n" . magit-section-forward)
	  ("C-c C-p" . magit-section-backward))
	 ("C-c C-g" . magit-diff-working-tree)))


;;;ファイルの自動再読み込み（Auto Revert）
(leaf autorevert
  :config


    (global-auto-revert-mode 1))


;;goto-line
(global-set-key (kbd "C-x C-g") 'goto-line)








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

;;ccls を導入
(leaf ccls
  :ensure t
  :after lsp-mode
  :init
  (setq ccls-executable "/usr/bin/ccls")  ;; cclsの実行可能ファイルのパスを適切に設定
  :config
  (setq lsp-enable-snippet nil
        lsp-enable-semantic-highlighting t
        lsp-ccls-enable t))


;;;; LSPモードの設定とキーバインドの調整(ref ::https://qiita.com/kari_tech/items/4754fac39504dccfd7be )
(leaf lsp-mode
  :ensure t
  :commands lsp
;;  :hook ((c-mode-hook c++-mode-hook python-mode-hook) . lsp)
  :init
  ;;(setq lsp-prefer-flymake nil)  ;; FlymakeではなくFlycheckを使用
  (setq lsp-clients-clangd-args '("--header-insertion=never"))

  ;;   :custom
  ;; ((lsp-print-io . nil)
  ;;  ;; LSP通信のデバッグ出力を無効化
  ;;  (lsp-trace . nil)
  ;;  ;; LSPのトレースログを無効化
  ;;  (lsp-print-performance . nil)
  ;;  ;; パフォーマンスログを無効化
  ;;  (lsp-auto-guess-root . t)
  ;;  ;; プロジェクトのルートディレクトリを自動的に推測
  ;;  (lsp-document-sync-method . 'incremental)
  ;;  ;; ドキュメントの同期方法をインクリメンタルに設定
  ;;  (lsp-response-timeout . 5)
  ;;  ;; LSPサーバーからのレスポンスのタイムアウト時間を5秒に設定
  ;;  (lsp-prefer-flymake . 'flymake)
  ;;  ;; 警告やエラーを表示するためにflymakeを使用
  ;;  (lsp-enable-completion-at-point . nil))
  ;;  ;; ポイントでの補完を無効化
  :config
  ;; キーバインドをGTAGSからLSPに再割り当て
  (define-key lsp-mode-map (kbd "M-.") #'lsp-find-definition)
  (define-key lsp-mode-map (kbd "M-,") #'lsp-find-references)
  (define-key lsp-mode-map (kbd "M-s") #'lsp-find-implementation)
  (define-key lsp-mode-map (kbd "M-t") #'lsp-find-declaration))

;; lsp-pyright の設定
(leaf lsp-pyright
  :ensure t
  :after lsp-mode
 ;; :hook (python-mode-hook . (lambda ()
 ;;                             (require 'lsp-pyright)
 ;;                             (lsp)))  ;; Pythonファイルで自動的にlspを起動
)
;; LSP UIの追加設定

(leaf lsp-ui
  :ensure t
  :custom
  ((lsp-ui-doc-enable . t)
   ;; LSP UI ドキュメントの表示を有効化
   (lsp-ui-doc-header . t)
   ;; ドキュメントのヘッダー表示を有効化
   (lsp-ui-doc-include-signature . t)
   ;; ドキュメントにシグネチャを含める
   (lsp-ui-doc-position . 'top)
   ;; ドキュメントの表示位置を上部に設定
   (lsp-ui-doc-max-width . 150)
   ;; ドキュメントの最大幅を150に設定
   (lsp-ui-doc-max-height . 30)
   ;; ドキュメントの最大高さを30に設定
   (lsp-ui-doc-use-childframe . t)
   ;; ドキュメントを子フレームで表示
   (lsp-ui-doc-use-webkit . t)
   ;; Webkitを使用してドキュメントを表示
   (lsp-ui-flycheck-enable . nil)
   ;; lsp-uiによるflycheckの有効化を無効に
   (lsp-ui-sideline-enable . nil)
   ;; サイドラインの情報表示を無効に
   (lsp-ui-sideline-show-diagnostics . nil)
   ;; 診断をサイドラインに表示しない
   (lsp-ui-sideline-show-code-actions . nil))
   ;; コードアクションをサイドラインに表示しない
  :preface
  (defun ladicle/toggle-lsp-ui-doc ()
    (interactive)
    (if lsp-ui-doc-mode
        (progn
          (lsp-ui-doc-mode -1)
          (lsp-ui-doc--hide-frame))
      (lsp-ui-doc-mode 1)))
  )
  ;; ドキュメント表示の切り



;; ;;eglot(https://github.com/joaotavora/eglot)(https://rn.nyaomin.info/entry/2024/01/16/224657)LSPの簡略版だがうまくつかえない
;; (leaf eglot
;;       :ensure t
;;       :config
;;       (add-to-list 'eglot-server-programs '((c-mode c++-mode python-mode js-mode js-ts-mode typescript-mode typescript-ts-mode) . (eglot-deno "deno" "lsp")))
;;       (defclass eglot-deno (eglot-lsp-server) () :documentation "A custom class for deno lsp.")
;;       (cl-defmethod eglot-initialization-options ((server eglot-deno))
;;         "Passes through required deno initialization options"
;;         (list :enable t :lint t))
;;      ;; (setq eglot-ignored-server-capabilities '(:documentHighlightProvider :inlayHintProvider))
;;       (setq eldoc-echo-area-use-multiline-p nil)
;;       :hook
;;       ((sh-mode
;;         c-mode
;;         c++-mode
;;         python-mode
;;         ruby-mode
;;         rust-mode
;;         html-mode
;;         css-mode
;;         js-mode
;;         ) . eglot-ensure)
;;       )


;;eglot(https://github.com/joaotavora/eglot)
;;  (leaf eglot
;;    :ensure t
;; ;;   :hook (
;; ;;          (c-mode-hook . eglot-ensure)
;; ;;          (c++-mode-hook . eglot-ensure)
;; ;;          (python-mode-hook . eglot-ensure))
;; ;;   :config
;; ;;   ;; オプション設定（必要に応じて）
;;    ;;   (setq eglot-keep-workspace-alive nil)  ;; Emacs終了時にLSPサーバを自動的にシャットダウン
;;    ) 


;;companyの設定
(leaf company
  :ensure t
  :init
  ;; (global-company-mode)  ;; グローバルにcompanyを有効化する場合はこのコメントを外す
 ;; :hook ((c-mode-hook c++-mode-hook python-mode-hook) . company-mode)  ;; フックを有効にする場合はこのコメントを外す
  :custom
  ;; (company-lsp-cache-candidates . t) ;; 候補のキャッシュを常に使用
  ;; (company-lsp-async . t)           ;; 非同期補完を有効化
  ;; (company-lsp-enable-recompletion . nil)  ;; 再補完を無効化
  (company-idle-delay . 0.0)        ;; 自動補完の遅延なし
  (company-minimum-prefix-length . 1)   ;; 1文字入力されたら補完を開始
  )

;; ;; flycheckの設定
;; (leaf flycheck
;;   :ensure t
;;   :init
;;   (global-flycheck-mode))

;; Ediffのハイライト色を設定
;; (custom-set-faces
;;  '(ediff-current-diff-A ((t (:background "#1c1c1c" :foreground "#ffffff"))))
;;  '(ediff-current-diff-B ((t (:background "#1c1c1c" :foreground "#ffffff"))))
;;  '(ediff-current-diff-C ((t (:background "#1c1c1c" :foreground "#ffffff"))))
;;  '(ediff-even-diff-A ((t (:background "#262626"))))
;;  '(ediff-even-diff-B ((t (:background "#262626"))))
;;  '(ediff-even-diff-C ((t (:background "#262626"))))
;;  '(ediff-odd-diff-A ((t (:background "#262626"))))
;;  '(ediff-odd-diff-B ((t (:background "#262626"))))
;;  '(ediff-odd-diff-C ((t (:background "#262626")))))



;; 署名検証を無効にする
;;(setq package-check-signature nil)
;;(require 'gnu-elpa-keyring-update)

;;which-key
(leaf leaf-keywords
  :ensure t
  :config
  (leaf which-key
    :ensure t
    :config
    (which-key-mode)
   (which-key-setup-side-window-right))
  )



;;treemacs 
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
 :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))



;; ;; 起動プロファイルの収集
;; (add-hook 'emacs-startup-hook
;;           (lambda ()
;;             (message "Emacs 起動時間: %s" (emacs-init-time))))

;; ;; プロファイル結果の出力
;; (leaf esup
;;   :ensure t)
;; (require 'esup)


;;インデント揃え
(global-set-key (kbd "C-c C-r") 'indent-region)




;; helm, projectile, helm-projectile の設定
(leaf helm
  :ensure t
  :config
  (progn
    (helm-mode 1)  
    (global-set-key (kbd "M-x") 'helm-M-x)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)
;;    (global-set-key (kbd "C-x b") 'helm-mini)
    ;; (global-set-key (kbd "M-y") 'helm-show-kill-ring)
  
    ;(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
;;    (define-key helm-map (kbd "C-z") 'helm-select-action) ; list actions using C-z
  ))
;;projectile

;; (leaf helm-ag
;;   :ensure t
;;   :after helm
;;   :custom
;;   (helm-ag-base-command . "ag --nocolor --nogroup")
;;   (helm-ag-insert-at-point . 'symbol)
;;   (helm-ag-command-option . "--all-text")
;;   (helm-ag-fuzzy-match . t))

(leaf projectile
  :ensure t
  :require t
  :config
  (progn
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
    (projectile-mode +1)))

(leaf helm-projectile
  :ensure t
  :after (helm projectile)
  :config
  (helm-projectile-on)
  (setq projectile-completion-system 'helm)
  :bind
  (("C-c p h" . helm-projectile)
   ("C-c p SPC" . helm-projectile-grep)))  ;; ここでキーをバインド
 

;; copilot.elのインストールと設定
(leaf copilot
  :straight (copilot :type git :host github :repo "zerolfx/copilot.el" :files ("*.el"))
  :require t
  :config
;;  (add-hook 'prog-mode-hook 'copilot-mode)
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "C-TAB") 'copilot-accept-completion-by-word)
  (define-key copilot-completion-map (kbd "C-<tab>") 'copilot-accept-completion-by-word)

  ;; Warningを無効にする設定
  (setq copilot-infer-indentation-offset 'disable)
  (setq copilot--disable-infer-indentation t))


;; shell-popの設定
(leaf shell-pop
  :ensure t
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


;; eshell-git-promptの設定
(leaf eshell-git-prompt
  :ensure t
  :config
  (eshell-git-prompt-use-theme 'git-radar))

(setq enable-local-variables t)

;; ;;projectile-bookmarks.eld ファイルの更新:
;; (setq projectile-enable-caching nil)
;; (setq projectile-known-projects-file "/dev/null")
;; (setq projectile-cache-file "/dev/null")

;; ;;straight ディレクトリの更新:
;; (setq straight-check-for-modifications nil)
;; (setq straight-check-for-modifications '(check-on-save find-when-checking))

;; ;;auto-save-list ディレクトリの設定:
;; (setq auto-save-default nil)
;; (setq auto-save-list-file-prefix nil)



;; (setq treemacs-persist-file "/dev/null")
;; (setq treemacs-last-error-persist-file "/dev/null")


;; (setq shell-file-name "/dev/null")


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

(add-hook 'c-mode-hook 'my-c-comment-style)
(add-hook 'c-mode-hook
          (lambda ()
            (local-set-key (kbd "M-;") 'my-c-comment-dwim)))

(add-hook 'c++-mode-hook 'my-c-comment-style)
(add-hook 'c++-mode-hook
          (lambda ()
            (local-set-key (kbd "M-;") 'my-c-comment-dwim)))

