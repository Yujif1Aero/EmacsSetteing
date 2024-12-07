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


;;; init.el --- init file for Emacs -*- coding: utf-8 ; lexical-binding: t -*-

;; Author: Masayuki Hatta <mhatta@gnu.org>

;;; Commentary:

;; A boilerplate configuration file for modern Emacs experience.

;;; Code:

;;;
;;; straight.el
;;;
(setq straight-repository-branch "develop") ;; use the develop branch of straight.el

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

(setq straight-vc-git-default-clone-depth 1) ;; shallow clone

;; See https://github.com/raxod502/straight.el#summary-of-options-for-package-modification-detection
(when (eq system-type 'windows-nt)
  (if (and (executable-find "watchexec")
           (executable-find "python3")
	   (executable-find "diff"))
      (setq straight-check-for-modifications '(watch-files find-when-checking))
    (setq straight-check-for-modifications '(check-on-save find-when-checking))))

;;;
;;; leaf.el
;;;
;; (eval-and-compile
;;   (straight-use-package 'leaf)
;;   (straight-use-package 'leaf-keywords)
;;   (leaf-keywords-init)
;;   )

(leaf leaf
  :require t
  :init
  (leaf leaf-convert
    :straight t
    )

  (leaf leaf-tree
    :straight t
    :blackout t
    :custom
    (imenu-list-position . 'left)
    )
  )

;;;
;;; Blackout
;;;
(leaf blackout
  :leaf-defer nil
  :straight t
  :config
  ;; shut up eldoc in modeline
  (leaf eldoc :blackout t)
  )

;;;
;;; Defer loading several libraries (for speeding up)
;;;
(leaf Libraries
  :config
  (leaf cl-lib
    :leaf-defer t
    )
  (leaf dash
    :straight t
    :leaf-defer t
    )
  )

;;;
;;; Garbage Collector Magic Hack
;;;
(leaf gcmh
  :leaf-defer nil
  :straight t
  :blackout t
  :global-minor-mode gcmh-mode
  )

;;;
;;; Language settings
;;;
(leaf Settings
  :config
  (leaf Language
    :config
    (set-language-environment "Japanese")
    (prefer-coding-system 'utf-8)
    (set-default 'buffer-file-coding-system 'utf-8)
    )

  ;; (leaf Fonts
  ;;   :config
  ;;   ;; unicode-fonts
  ;;   (leaf unicode-fonts
  ;;     :straight t
  ;;     :config
  ;;     (unicode-fonts-setup)
  ;;     )

  ;;   (when (eq system-type 'windows-nt)
  ;;     (set-face-attribute 'default nil :family "Consolas" :height 120) ;; CHANGEME
  ;;     (set-fontset-font 'nil 'japanese-jisx0208
  ;;    			(font-spec :family "Yu Gothic UI"))) ;; CHANGEME
  ;;   (when (eq system-type 'gnu/linux)
  ;;     ;; Install e.g. fonts-inconsolata & fonts-ipaexfont packages on Debian/Ubuntu
  ;;     (set-frame-font "Inconsolata-14") ;; CHANGEME
  ;;     (set-fontset-font t 'japanese-jisx0208 (font-spec :family "IPAExGothic"))) ;; CHANGEME
  ;;   )

  ;; (leaf Misc
  ;;   :config
  ;;   (define-key key-translation-map [?\C-h] [?\C-?])
  ;;   (column-number-mode t)
  ;;   :custom
  ;;   '((user-full-name . "Your Name") ;; CHANGEME
  ;;     (user-login-name . "yourlogin") ;; CHANGEME
  ;;     (user-mail-address . "you@example.com") ;; CHANGEME
  ;;     (inhibit-startup-message . t)
  ;;     (delete-by-moving-to-trash . t)
  ;;     (kinsoku-limit . 10)
  ;;     ;; For text-only web browsing
  ;;     ;; (browse-url-browser-function . 'eww-browse-url)
  ;;     )
  ;;   )
  )


;;;
;;; Japanese IME
;;;
(leaf Japanese-IME
  :config
  ;; tr-ime (for Windows)
  (leaf tr-ime
    ;; should work on terminal too
    :if (and (eq system-type 'windows-nt) (display-graphic-p))
    :straight t
    :config
    (tr-ime-advanced-install 'no-confirm)
    (setq default-input-method "W32-IME")
    (w32-ime-initialize)
    (setq-default w32-ime-mode-line-state-indicator "[--]")
    (setq w32-ime-mode-line-state-indicator-list '("[--]" "[あ]" "[--]"))
    ;; Fonts used during henkan
    (modify-all-frames-parameters '((ime-font . "Yu Gothic UI-12"))) ;; CHANGEME
    ;; IME control
    (wrap-function-to-control-ime 'universal-argument t nil)
    (wrap-function-to-control-ime 'read-string nil nil)
    (wrap-function-to-control-ime 'read-char nil nil)
    (wrap-function-to-control-ime 'read-from-minibuffer nil nil)
    (wrap-function-to-control-ime 'y-or-n-p nil nil)
    (wrap-function-to-control-ime 'yes-or-no-p nil nil)
    (wrap-function-to-control-ime 'map-y-or-n-p nil nil)
    (wrap-function-to-control-ime 'register-read-with-preview nil nil)
    )

  ;; Mozc (for GNU/Linux)
  (leaf mozc
    :if (eq system-type 'gnu/linux)
    :straight t
    :config
    (setq default-input-method "japanese-mozc")
    ;; mozc-posframe
    (leaf mozc-cand-posframe
      :if (eq system-type 'gnu/linux)
      :after mozc
      :straight t
      :config
      (setq mozc-candidate-style 'posframe)
      )
    )

  ;; ddskk
  (leaf ddskk
    :straight t
    :bind
    (("C-x C-j" . skk-mode)
     ("C-x j"   . skk-mode))
    )
  )

;;;
;;; Looks
;;;
(leaf Looks
  :config

  ;; Theme (Modus)
  (leaf modus-themes
    :straight t
    :leaf-defer nil
    :init
    ;; Add all your customizations prior to loading the themes
    (setq modus-themes-italic-constructs t
          modus-themes-bold-constructs nil
          modus-themes-region '(bg-only no-extend))
    :config
    ;; Load the theme of your widget-choice-match
    (load-theme 'modus-vivendi :no-confirm) ;; OR modus-operandi
    :bind ("<f5>" . modus-themes-toggle)
    )

  ;; ;; Theme (zenburn)
  ;; (leaf zenburn-theme
  ;;   :straight t
  ;;   :config
  ;;   (load-theme 'zenburn t)
  ;;   )
  
  ;; dashboard
  (leaf dashboard
    :straight t
    :config
    (dashboard-setup-startup-hook)
    )

  ;; all-the-icons
  (leaf all-the-icons
    :if (display-graphic-p)
    :straight t
    :config
    ;;    (all-the-icons-install-fonts)
    )
  :custom
  ;; No tool bar
  ;;  '((tool-bar-mode . nil)
  ;; No scroll bar
  ;; (set-scroll-bar-mode nil)
  )

;;;
;;; minibuffer completion
;;;
(leaf Minibuf-completion
  :config
  ;; corfu
  (leaf corfu
    :straight (corfu :files (:defaults "extensions/*")
                     :includes (corfu-info
				corfu-history
				corfu-popupinfo)
		     )
    :init
    (setq corfu-auto t
	  corfu-quit-no-match t
	  corfu-popupinfo-delay 0.3
	  completion-cycle-threshold 3
	  )
    :global-minor-mode (global-corfu-mode corfu-popupinfo-mode)
    :config
    (define-key corfu-map
		(kbd "SPC") #'corfu-insert-separator)
    (defun corfu-enable-always-in-minibuffer ()
      "Enable Corfu in the minibuffer if Vertico/Mct are not active."
      (unless (or (bound-and-true-p mct--active)
		  (bound-and-true-p vertico--input)
		  (eq (current-local-map) read-passwd-map))
	;; (setq-local corfu-auto nil) Enable/disable auto completion
	(setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                    corfu-popupinfo-delay nil)
	(corfu-mode 1)))
    (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)

    (defun corfu-beginning-of-prompt ()
      "Move to beginning of completion input."
      (interactive)
      (corfu--goto -1)
      (goto-char (car completion-in-region--data)))

    (defun corfu-end-of-prompt ()
      "Move to end of completion input."
      (interactive)
      (corfu--goto -1)
      (goto-char (cadr completion-in-region--data)))
    (define-key corfu-map [remap move-beginning-of-line] #'corfu-beginning-of-prompt)
    (define-key corfu-map [remap move-end-of-line] #'corfu-end-of-prompt)

    (add-hook 'eshell-mode-hook
              (lambda ()
		(setq-local corfu-auto nil)
		(corfu-mode)))

    (defun corfu-send-shell (&rest _)
      "Send completion candidate when inside comint/eshell."
      (cond
       ((and (derived-mode-p 'eshell-mode) (fboundp 'eshell-send-input))
	(eshell-send-input))
       ((and (derived-mode-p 'comint-mode)  (fboundp 'comint-send-input))
	(comint-send-input))))

    (advice-add #'corfu-insert :after #'corfu-send-shell)

    ;; corfu-terminal
    (leaf corfu-terminal
      :straight '(corfu-terminal :type git :repo "https://codeberg.org/akib/emacs-corfu-terminal.git")
      :after corfu
      :config
      (unless (display-graphic-p)
	(corfu-terminal-mode +1))
      )
    ;; corfu-history
    (leaf corfu-history
      :after corfu
      :config
      (with-eval-after-load 'safehist
	(cl-pushnew 'corfu-history savehist-additional-variables))
      (corfu-history-mode)
      )
    )

  ;; pcmpl-args
  (leaf pcmpl-args
    :straight t
    )
  
  ;; Dabbrev
  (leaf dabbrev
    :straight t
    :blackout t
    ;; Swap M-/ and C-M-/
    :bind (("M-/" . dabbrev-completion)
           ("C-M-/" . dabbrev-expand))
    ;; Other useful Dabbrev configurations.
    :custom
    (dabbrev-ignored-buffer-regexps '("\\.\\(?:pdf\\|jpe?g\\|png\\)\\'"))
    )

  ;; vertico
  (leaf vertico
    :straight (vertico :files (:defaults "extensions/*")
                       :includes (vertico-directory)
		       )
    :init
    (vertico-mode)
    (setq vertico-count 20)
    :config
    ;; vertico-directory
    (leaf vertico-directory
      :straight t
      :config
      (define-key vertico-map (kbd "C-l") #'vertico-directory-up)
      (define-key vertico-map "RET" #'vertico-directory-enter)  ;; enter dired
      (define-key vertico-map "DEL" #'vertico-directory-delete-char)
      (define-key vertico-map "M-DEL" #'vertico-directory-delete-word)
      :hook
      (rfn-eshadow-update-overlay-hook . vertico-directory-tidy)
      )
    )

  ;; ;; consult
  ;; (leaf consult
  ;;   :straight t
  ;;   :bind
  ;;   (("C-s" . consult-line))
  ;;   )

  ;; orderless
  (leaf orderless
    :straight t
    :require t
    :after migemo
    :config
    ;; Using migemo with orderless
    (defun orderless-migemo (component)
      (let ((pattern (migemo-get-pattern component)))
	(condition-case nil
            (progn (string-match-p pattern "") pattern)
          (invalid-regexp nil))))
    (orderless-define-completion-style orderless-default-style
      (orderless-matching-styles '(orderless-initialism
				   orderless-literal
				   orderless-regexp)))
    (orderless-define-completion-style orderless-migemo-style
      (orderless-matching-styles '(orderless-initialism
				   orderless-literal
				   orderless-regexp
				   orderless-migemo)))
    (setq completion-category-overrides
          '((command (styles orderless-default-style))
            (file (styles orderless-migemo-style))
            (buffer (styles orderless-migemo-style))
            (symbol (styles orderless-default-style))
            (consult-location (styles orderless-migemo-style))
            (consult-multi (styles orderless-migemo-style))
            (org-roam-node (styles orderless-migemo-style))
            (unicode-name (styles orderless-migemo-style))
            (variable (styles orderless-default-style))))
    (setq orderless-matching-styles '(orderless-literal orderless-regexp orderless-migemo))
    :custom
    (completion-styles . '(orderless basic))
    )

  ;; marginalia
  (leaf marginalia
    :straight t
    :global-minor-mode marginalia-mode
    :init
    (define-key minibuffer-local-map (kbd "C-M-a") #'marginalia-cycle)
    )

  ;: all-the-icons-completion
  (leaf all-the-icons-completion
    :after (marginalia all-the-icons)
    :straight t
    :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
    :global-minor-mode all-the-icons-completion-mode
    )
  
  ;; cape
  (leaf cape
    :straight t
    :config
    (add-to-list 'completion-at-point-functions #'cape-file)
    (add-to-list 'completion-at-point-functions #'cape-tex)
;;    (add-to-list 'completion-at-point-functions #'cape-dabbrev)
    (add-to-list 'completion-at-point-functions #'cape-keyword)
    (add-to-list 'completion-at-point-functions #'cape-abbrev)
    (add-to-list 'completion-at-point-functions #'cape-ispell)
    (add-to-list 'completion-at-point-functions #'cape-symbol)
    ;; Silence the pcomplete capf, no errors or messages!
    (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)
    ;; Ensure that pcomplete does not write to the buffer
    ;; and behaves as a pure `completion-at-point-function'.
    (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)
    )

  ;; kind-icon
  (leaf kind-icon
    :straight t
    :config
    (setq kind-icon-default-face 'corfu-default)
    (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
    )

  ;; embark
  (leaf embark
    :straight t
    :bind
    (("C-." . embark-act)
     ("C-;" . embark-dwim)
     ("C-h B" . embark-bindings))
    :init
    ;; Optionally replace the key help with a completing-read interface
    (setq prefix-help-command #'embark-prefix-help-command)
    :config
    ;; Hide the mode line of the Embark live/completions buffers
    (add-to-list 'display-buffer-alist
		 '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                   nil
                   (window-parameters (mode-line-format . none))))
    (leaf embark-consult
      :straight t
      :hook
      (embark-collect-mode . consult-preview-at-point-mode))
    )

  ;; affe
  (leaf affe
    :straight t
    :after consult
    :config
    (consult-customize affe-grep :preview-key (kbd "M-."))
    (defvar affe-orderless-regexp "")
    (defun affe-orderless-regexp-compiler (input _type)
      (setq affe-orderless-regexp (orderless-pattern-compiler input))
      (cons affe-orderless-regexp
            (lambda (str) (orderless--highlight affe-orderless-regexp str))))
    (setq affe-regexp-compiler #'affe-orderless-regexp-compiler)
    )

  ;; migemo
  (leaf migemo
    :if (executable-find "cmigemo")
    :straight t
    :require t
    :config
    (setq migemo-command "cmigemo"
          migemo-options '("-q" "-e")
	  migemo-user-dictionary nil
          migemo-regex-dictionary nil
          migemo-coding-system 'utf-8-unix)
    (when (eq system-type 'gnu/linux)
      (setq migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict"))
    (when (eq system-type 'windows-nt)
      ;; needs absolute path
      (setq migemo-dictionary (expand-file-name "~/scoop/apps/cmigemo/current/cmigemo-mingw64/share/migemo/utf-8/migemo-dict")))
    (migemo-init)
    )
  )

;;;
;;; org-mode
;;;
(leaf Org-mode
  :config
  ;; org
  (leaf org
    :straight t
    :leaf-defer t
    :init
    (setq org-directory "~/Org") ;; CHANGEME
    (unless (file-exists-p org-directory)
      (make-directory org-directory))
    (defun org-buffer-files ()
      "Return list of opened Org mode buffer files."
      (mapcar (function buffer-file-name)
	      (org-buffer-list 'files)))
    (defun show-org-buffer (file)
      "Show an org-file FILE on the current buffer."
      (interactive)
      (if (get-buffer file)
	  (let ((buffer (get-buffer file)))
	    (switch-to-buffer buffer)
	    (message "%s" file))
	(find-file (concat org-directory "/" file))))
    :bind
    (("\C-ca" . org-agenda)
     ("\C-cc" . org-capture)
     ("\C-ch" . org-store-link)
     ("C-M--" . #'(lambda () (interactive)
		    (show-org-buffer "gtd.org")))
     ("C-M-^" . #'(lambda () (interactive)
		    (show-org-buffer "notes.org")))
     ("C-M-~" . #'(lambda () (interactive)
    		    (show-org-buffer "kb.org")))
     )
    :config
    (setq  org-agenda-files (list org-directory)
	   org-default-notes-file "notes.org"
	   org-log-done 'time
	   org-startup-truncated nil
	   org-startup-folded 'content
	   org-use-speed-commands t
	   org-enforce-todo-dependencies t)
    (remove (concat org-directory "/archives") org-agenda-files)
    (setq org-todo-keywords
	  '((sequence "TODO(t)" "SOMEDAY(s)" "WAITING(w)" "|" "DONE(d)" "CANCELED(c@)")))
    (setq org-refile-targets
	  (quote ((nil :maxlevel . 3)
		  (org-buffer-files :maxlevel . 1)
		  (org-agenda-files :maxlevel . 3))))
    (setq org-capture-templates
	  '(("t" "Todo" entry (file+headline "gtd.org" "Inbox")
	     "* TODO %?\n %i\n %a")
            ("n" "Note" entry (file+headline "notes.org" "Notes")
	     "* %?\nEntered on %U\n %i\n %a")
            ("j" "Journal" entry (function org-journal-find-location)
	     "* %(format-time-string org-journal-time-format)%^{Title}\n%i%?")
	    ("h" "Hugo post" entry (file+olp "jamhattaorg.org" "Blog Ideas")
             (function org-hugo-new-subtree-post-capture-template))
	    ))
    ;; Populates only the EXPORT_FILE_NAME property in the inserted headline.
    (with-eval-after-load 'org-capture
      (defun org-hugo-new-subtree-post-capture-template ()
	"Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
	(let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
               (fname (org-hugo-slug title)))
	  (mapconcat #'identity
                     `(
                       ,(concat "*** TODO " title)
                   ":PROPERTIES:"
                   ,(concat ":EXPORT_FILE_NAME: " fname)
		   ":EXPORT_HUGO_CUSTOM_FRONT_MATTER: :share true :featured false :slug :image "
		   ":EXPORT_DESCRIPTION: "
                   ":END:"
                   "%?\n")          ;Place the cursor here finally
                     "\n"))))
    )

  ;; org-babel
  (leaf ob
    :after org
    :defun org-babel-do-load-languages
    :config
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (shell . t)
       (python . t)
       (R . t)
       (ditaa . t)
       (plantuml . t)
       ))
    ;; Ditaa jar path
    ;; cf. https://tamura70.hatenadiary.org/entry/20100317/org
    (when (eq system-type 'windows-nt)
      (setq org-ditaa-jar-path (expand-file-name "~/jditaa.jar")) ;; CHANGEME
      )
    (when (eq system-type 'gnu/linux)
      (setq org-ditaa-jar-path "/usr/share/ditaa/ditaa.jar")
      )
    (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
    ;; PlantUML jar path
    (when (eq system-type 'windows-nt)
      (setq org-plantuml-jar-path (expand-file-name "~/plantuml.jar")) ;; CHANGEME
      )
    (when (eq system-type 'gnu/linux)
      (setq org-plantuml-jar-path "/usr/share/plantuml/plantuml.jar")
      )
    )
  
  ;; org-superstar
  (leaf org-superstar
    :after org
    :straight t
    :custom
    (org-superstar-headline-bullets-list . '("◉" "★" "○" "▷" "" ""))
    :hook
    (org-mode-hook (lambda () (org-superstar-mode 1)))
    )

  ;; org-journal
  (leaf org-journal
    :after org
    :straight t
    :config
    (setq org-journal-dir (concat org-directory "/journal")
	  org-journal-enable-agenda-integration t)
    (defun org-journal-find-location ()
      ;; Open today's journal, but specify a non-nil prefix argument in order to
      ;; inhibit inserting the heading; org-capture will insert the heading.
      (org-journal-new-entry t)
      ;; Position point on the journal's top-level heading so that org-capture
      ;; will add the new entry as a child entry.
      (goto-char (point-min))
      )
    )

  ;; org-cliplink
  (leaf org-cliplink
    :after org
    :straight t
    :bind
    ("C-x p i" . org-cliplink)
    )

  ;; org-download
  (leaf org-download
    :after org
    :straight t
    :config
    (setq-default org-download-image-dir (concat org-directory "/pictures"))
    )

  ;; org-web-tools
  (leaf org-web-tools
    :after org
    :straight t
    )

  ;; toc-org
  (leaf toc-org
    :after org markdown-mode
    :straight t
    ;;:commands toc-org-enable
    :config
    (add-hook 'org-mode-hook 'toc-org-enable)
    ;; enable in markdown, too
    (add-hook 'markdown-mode-hook 'toc-org-mode)
    (define-key markdown-mode-map (kbd "\C-c\C-o") 'toc-org-markdown-follow-thing-at-point)
    )

  ;; ox-hugo
  (leaf ox-hugo
    :after ox
    :straight t
    :require t
    )

  ;; ox-qmd
  (leaf ox-qmd
    :after ox
    :straight t
    :require t
    )

  ;; org2blog
  (leaf org2blog
    :after org
    ;; the latest version doesn't work
    :straight (org2blog :type git :host github :repo "sachac/org2blog")
    :leaf-autoload org2blog-autoloads
    :commands org2blog-user-login
    :config
    (setq org2blog/wp-use-sourcecode-shortcode t)
    (setq org2blog/wp-blog-alist
          `(("wordpress1"
	     :url "https://www.example.com/xmlrpc.php" ;; CHANGEME
             :username ,(car (auth-source-user-and-password "wordpress1")) ;; CHANGEME
             :password ,(cadr (auth-source-user-and-password "wordpress1")) ;; CHANGEME
	     )
	    ))
    (setq org2blog/wp-buffer-template
	  "#+TITLE: 
#+CATEGORY: 
#+TAGS: 
#+OPTIONS:
#+PERMALINK: \n")
    )

  ;; org-roam
  (leaf org-roam
    :straight t
    :after org
    :bind
    ("C-c n l" . org-roam-buffer-toggle)
    ("C-c n f" . org-roam-node-find)
    ("C-c n g" . org-roam-graph)
    ("C-c n i" . org-roam-node-insert)
    ("C-c n c" . org-roam-capture)
    ;; Dailies
    ("C-c n j" . org-roam-dailies-capture-today)
    :config
    (setq org-roam-directory (concat org-directory "/org-roam"))
    (unless (file-exists-p org-directory)
      (make-directory org-roam-directory))
    ;; If you're using a vertical completion framework, you might want a more informative completion interface
    (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
    (org-roam-db-autosync-mode)
    ;; If using org-roam-protocol
    (require 'org-roam-protocol)
    )

  ;; org-roam-ui
  (leaf org-roam-ui
    :straight (org-roam-ui :host github :repo "org-roam/org-roam-ui" :branch "main" :files ("*.el" "out"))
    :after org-roam
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t)
    )
  )

;;;
;;; Modes
;;;

(leaf Modes
  :config
  ;; C/C++
  (leaf cc-mode
    :straight t
    :leaf-defer t
    )

  ;; Python
  (leaf python-mode
    :straight t
    :leaf-defer t
    )

  ;; Markdown
  (leaf Markdown
    :config
    ;; markdown-mode
    (leaf markdown-mode
      :straight t
      :leaf-defer t
      :mode ("\\.md\\'" . gfm-mode)
      )
    ;; markdown-preview-mode
    (leaf markdown-preview-mode
      :straight t
      )
    )

  ;; web-mode
  (leaf web-mode
    :straight t
    :leaf-defer t
    :after flycheck
    :defun flycheck-add-mode
    :mode (("\\.html?\\'" . web-mode)
           ("\\js\\'" . web-mode)
           ("\\.jscss\\'" . web-mode)
           ("\\.css\\'" . web-mode)
           ("\\.scss\\'" . web-mode)
           ("\\.xml\\'" . web-mode))
    :config
    (flycheck-add-mode 'javascript-eslint 'web-mode)
    )

  ;; plantuml-mode
  (leaf plantuml-mode
    :straight t
    :leaf-defer t
    :mode ("\\.plantuml\\'" . plantuml-mode)
    :config
    (setq plantuml-default-exec-mode 'jar)
    ;; PlantUML jar path
    (when (eq system-type 'windows-nt)
      (setq plantuml-jar-path (expand-file-name "~/plantuml.jar")) ;; CHANGEME
      )
    (when (eq system-type 'gnu/linux)
      (setq plantuml-jar-path "/usr/share/plantuml/plantuml.jar")
      )
    )
  
  ;; rainbow-mode
  (leaf rainbow-mode
    :straight t
    :leaf-defer t
    :blackout t
    :hook
    (web-mode-hook . rainbow-mode)
    )
  )

;;;
;;; Flycheck
;;;
(leaf Flycheck
  :config
  ;; flycheck
  (leaf flycheck
    :straight t
    :blackout t
    :hook
    (prog-mode-hook . flycheck-mode)
    :custom ((flycheck-display-errors-delay . 0.3)
             (flycheck-indication-mode . 'left-margin))
;;    :global-minor-mode global-flycheck-mode ;; CHANGEME
    :config
    (add-hook 'flycheck-mode-hook #'flycheck-set-indication-mode)
    (leaf flycheck-posframe
      :straight t
      :after flycheck
      :hook (flycheck-mode-hook . flycheck-posframe-mode)
      :config
      (flycheck-posframe-configure-pretty-defaults)
      )
    )
  ;; checker for textlint
  (flycheck-define-checker textlint
    "A linter for prose."
    :command ("textlint" "--format" "unix" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any " "))))
              (message (one-or-more not-newline)
                       (zero-or-more "\n" (any " ") (one-or-more not-newline)))
              line-end))
    :modes (text-mode markdown-mode gfm-mode org-mode web-mode))
  )
  
;;;
;;; Tree-sitter
;;;
(leaf Tree-sitter
  ;; tree-sitter
  (leaf tree-sitter
    :straight t
    )
  (leaf tree-sitter-langs
    :straight t
    )
  )

;;;
;;; Misc Tools
;;;
(leaf Tools
  :config
  ;; smartparens
  (leaf smartparens
    :straight t
    :blackout t
    :require smartparens-config
    :hook
    (prog-mode-hook . turn-on-smartparens-mode)
    :global-minor-mode show-smartparens-global-mode
    )

  ;; rainbow-delimiters
  (leaf rainbow-delimiters
    :straight t
    :hook
    (prog-mode-hook . rainbow-delimiters-mode)
    )

  ;; beacon
  (leaf beacon
    :straight t
    :blackout t
    :global-minor-mode beacon-mode
    )

  ;; google-this
  (leaf google-this
    :straight t
    :bind
    ("M-s g" . google-this-noconfirm)
    )

  ;; which-key
  (leaf which-key
    :straight t
    :blackout which-key-mode
    :config
    (which-key-mode)
    )

  ;; free-keys
  (leaf free-keys
    :straight t
    )

  ;; popwin
  (leaf popwin
    :straight t
    :global-minor-mode popwin-mode
    )

  ;; ripgrep
  (leaf ripgrep
    :straight t
    :bind
    ("M-s r" . ripgrep-regexp)
    )

  ;; projectile
  (leaf projectile
    :straight t
    :blackout t
    :config
    (projectile-mode t)
    )

  ;; yasnippet
  (leaf yasnippet
    :straight t
    :blackout yas-minor-mode
    :commands yas-global-mode
    :hook (after-init-hook . yas-global-mode)
    )

  ;; yasnippet-snippets
  (leaf yasnippet-snippets
    :straight t
    :after yasnippet
    )
  
  ;; atomic-chrome
  (leaf atomic-chrome
    :straight t
    :config
    (atomic-chrome-start-server)
    )

  ;; twittering-mode
  (leaf twittering-mode
    :straight t
    :init
    (setq twittering-use-master-password t)
    (setq twittering-allow-insecure-server-cert t)
    (when (eq system-type 'windows-nt)
      (setq twittering-curl-program "~/scoop/apps/curl/current/bin/curl.exe")
      )
    )

  ;; restart-emacs
  (leaf restart-emacs
    :straight t
    )

  ;; magit
  (leaf magit
    :straight t
    :bind
    ("C-x g" . magit-status)
    )

  ;; easy-hugo
  (leaf easy-hugo
    :straight t
    :config
    (setq easy-hugo-basedir "~/Hugo/myhugoblog") ;; CHANGEME
    (setq easy-hugo-url "https://www.myhugoblog.org") ;; CHANGEME
    (setq easy-hugo-bloglist
	  '(((easy-hugo-basedir . "~/Hugo/anotherhugoblog") ;; CHANGEME
	     (easy-hugo-url . "https://www.anotherhugoblog.org")))) ;; CHANGEME
    )

  ;; go-translate
  (leaf go-translate
    :straight t
    :bind ("C-c t" . gts-do-translate)
    :config
    (setq gts-translate-list '(("en" "ja") ("ja" "en")))
    (setq gts-default-translator
	  (gts-translator
	   :picker (gts-noprompt-picker)
	   :engines (list
		     (gts-deepl-engine
                      :auth-key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:xx" :pro nil) ;; CHANGEME
		     (gts-google-engine)
		     (gts-bing-engine))
 	   :render (gts-buffer-render)))
    )

  ;; elfeed
  (leaf elfeed
    :straight t
    :bind ("C-x w" . elfeed)
    :config
    (setq elfeed-feeds
	  '("http://nullprogram.com/feed/"
            "https://planet.emacslife.com/atom.xml")) ;; CHANGEME
    )
  
  ;; smart-jump
  (leaf smart-jump
    :straight t
    :config
    (smart-jump-setup-default-registers)
    )
  
  ;; dumb-jump
  (leaf dumb-jump
    :straight t
    :config
    (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
    )

  ;; recentf
  (leaf recentf
    :straight t
    :global-minor-mode recentf-mode
    )

  ;; savehist
  (leaf savehist
    :straight t
    :global-minor-mode savehist-mode
    )
  
  ;; esup
  (leaf esup
    :straight t
    )

  )

;;;
;;; Server
;;;
(leaf server
  :straight t
  :require t
  :config
  (defun my--server-start ()
    (let ((server-num 0))
      (while (server-running-p (unless (eq server-num 0) (concat "server" (number-to-string server-num))))
        (setq server-num (+ server-num 1)))
      (unless (eq server-num 0)
        (setq server-name (concat "server" (number-to-string server-num))))
      (server-start)
      (setq frame-title-format server-name)))
  (my--server-start)
)

;;;
;;; exec-path-from-shell
;;;
(leaf exec-path-from-shell
  :require t
  :if (memq window-system '(mac ns x))
  :straight t
  :init
  (exec-path-from-shell-initialize)
  )

;;;
;;; Local packages
;;;
(leaf Local
  :config
  ;; word-count-mode
  (leaf word-count
    :straight '(word-count :type git :host github
			   :repo "mhatta/word-count-mode")
    :bind ("\M-+" . word-count-mode)
    )

  ;; lookup-el
  (leaf lookup
    :leaf-defer t
    :straight nil
    :commands (lookup lookup-region lookup-pattern)
    :init
    (when (eq system-type 'windows-nt)
      (add-to-list 'load-path "~/.emacs.d/site-lisp/lookup")
      )
    :bind
    ("\C-cw" . lookup-pattern)
    ("\C-cW" . lookup)
    :init
    (setq lookup-enable-splash nil)
    )
  )

;;;
;;; Profiler (report)
;;;
;;(profiler-report)
;;(profiler-stop)

;;; init.el ends here

;; ;; yuji setting
;; 現在開いている各フレームに対してカーソル形状を適用
(dolist (frame (frame-list))
  (modify-frame-parameters frame '((cursor-type . box))))
(electric-pair-mode 1)
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(global-set-key "\C-x\C-b" 'buffer-menu)
;;次のwindowに移動

(define-key global-map (kbd "C-c o")'other-window)
                                        ;(define-key global-map (kbd "C-i")'other-window)
(windmove-default-keybindings)

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

;;;;Emacsのクリップボードとシステムクリップボードを同期
(setq select-enable-clipboard t)
(setq select-enable-primary t)

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

(leaf gruvbox-theme
(load-theme 'gruvbox-dark-medium t)
  :ensure t
  :config
  (load-theme 'gruvbox-dark-medium t)
  ;;(load-theme 'solarized-light t) ;; Solarized Light をロード
  ;; 以下はオプションのカスタマイズ
  :custom
  ((solarized-use-variable-pitch . nil)  ;; 可変幅フォントを無効化
   (solarized-scale-org-headlines . nil) ;; Org mode の見出しサイズ変更を無効化
   (solarized-high-contrast-mode-line . t))) ;; モードラインを高コントラストに

;; alpha
(if window-system
    (progn
      (set-frame-parameter nil 'alpha 95)))
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
;;xterm-mouse-mode をトグルする関数       
(defun toggle-xterm-mouse-mode ()
  (interactive)
  (if xterm-mouse-mode
      (progn
        (xterm-mouse-mode -1)
        (message "xterm-mouse-mode disabled"))
    (progn
      (xterm-mouse-mode 1)
      (message "xterm-mouse-mode enabled"))))

;; ;; キーバインドの設定（Ctrl + Alt + m にトグルを割り当て）
(global-set-key (kbd "C-M-m") 'toggle-xterm-mouse-mode)

;; 他のマウス設定
(mouse-wheel-mode 1)

;; マウスホイールのスクロール設定
(setq mouse-wheel-scroll-amount '( ((Alt) . 1)))  ;; 通常は3行、Shiftキーを押しながらは1行
(setq mouse-wheel-progressive-speed nil)  ;; スクロール速度を固定
(setq mouse-wheel-follow-mouse 't)  ;; マウスポインタの位置に従ってスクロール

;; ;; Smooth Scroll のオプション設定
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)
;;スクロールの加速
(setq mouse-wheel-progressive-speed t)

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

;; 直前のバッファに戻る
					;(global-set-key (kbd "M-[") 'switch-to-prev-buffer)
(global-set-key (kbd "C-M-[") 'previous-buffer)

;; 次のバッファに進む
					;(global-set-key (kbd "M-]") 'switch-to-next-buffer)
(global-set-key (kbd "C-M-]") 'next-buffer)

(leaf magit
  :ensure t
  :bind ((magit-mode-map
          ;; 通常のカーソル移動用に `C-n` と `C-p` を標準の移動コマンドに再バインド
          ("C-n" . next-line)
          ("C-p" . previous-line)
          ;; セクション移動用に `C-c C-n` と `C-c C-p` を `magit` の移動コマンドにバインド
          ("C-c C-n" . magit-section-forward)
          ("C-c C-p" . magit-section-backward))
         ;; 全体のキーバインド設定
         ("C-c C-g" . magit-diff-working-tree)))


;;;ファイルの自動再読み込み（Auto Revert）
(leaf autorevert
  :config


    (global-auto-revert-mode 1))

;; ;; gnu-global->LSPに比べると精度が良くない
(setq-local imenu-create-index-function #'ggtags-build-imenu-index)

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
(leaf lsp-mode
  :ensure t
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
(leaf lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :config
  (lsp-treemacs-sync-mode 1) ;; Treemacs で LSP シンボルを表示
  :bind
  (("C-c C-t" . lsp-treemacs-symbols))) ;; Treemacs シンボルビューを表示


;;companyの設定
(leaf company
  :ensure t
  :init
  (global-company-mode) ;; グローバルにcompanyを有効化する場合はこのコメントを外す
;;  :hook ((c-mode-hook c++-mode-hook python-mode-hook) . company-mode) ;; フックを有効にする場合はこのコメントを外す
  :custom
  ;; (company-lsp-cache-candidates . t) ;; 候補のキャッシュを常に使用
  ;; (company-lsp-async . t)           ;; 非同期補完を有効化
  ;; (company-lsp-enable-recompletion . nil)  ;; 再補完を無効化
  (company-idle-delay . 0.2)        ;; 自動補完の遅延なし
  (company-minimum-prefix-length . 2)   ;; 1文字入力されたら補完を開始
  :config
  (add-hook 'eshell-mode-hook (lambda () (company-mode -1))) ;; eshellでは無効化
  )


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

;;インデント揃え
(global-set-key (kbd "C-c C-r") 'indent-region)
;; leaf を使った clang-format の設定
(leaf clang-format
  :ensure t
  :bind (("C-c C-j" . clang-format-region)    ;; 選択範囲にフォーマットを適用
         ("C-c j" . clang-format-buffer))    ;; バッファ全体にフォーマットを適用
  :config
  ;; C/C++モードにのみclang-formatを適用
  (add-hook 'c-mode-hook #'clang-format-buffer)  ;; C言語ファイルを開いたときにclang-formatを適用
  (add-hook 'c++-mode-hook #'clang-format-buffer)) ;; C++ファイルを開いたときにclang-formatを適用

;; helm, projectile, helm-projectile の設定
(leaf helm
  :ensure t
  :config
  ;; (helm-mode 1)
  ;; (with-eval-after-load 'helm
  ;;   (define-key helm-map (kbd "C-n") 'helm-next-line)
  ;;   (define-key helm-map (kbd "C-p") 'helm-previous-line)
  ;;   (define-key helm-map (kbd "C-v") 'helm-next-page)
  ;;   (define-key helm-map (kbd "M-v") 'helm-previous-page)
  ;;   (define-key helm-map (kbd "C-g") 'keyboard-quit)
  ;;   (define-key helm-map (kbd "C-x o") 'other-window)
  ;;   (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
  ;;   (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action))
  ;; :bind (("M-x" . helm-M-x)
  ;;        ("C-x C-f" . helm-find-files)
  ;;        ("C-x C-d" . dired)
  ;;        ("C-x C-d" . helm-browse-project))
  (progn
    (helm-mode 1)  
    (global-set-key (kbd "M-x") 'helm-M-x)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)
    (global-set-key (kbd "M-y") 'helm-show-kill-ring)
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
  )
  )

(leaf helm-ag
  :ensure t
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
  :ensure t
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
  :ensure t
  :after (helm projectile)
  :config
  (helm-projectile-on)
  (setq projectile-completion-system 'helm)
  :bind
  (("C-c p h" . helm-projectile)
  ("C-c p n" . helm-projectile-grep)
   )
  )


;; copilot.elのインストールと設定（最小化）
;; copilot.elのインストールと設定
(leaf copilot
  :straight (copilot :type git :host github :repo "zerolfx/copilot.el" :files ("*.el"))
  :require t
  :config
  (add-hook 'prog-mode-hook 'copilot-mode) ;;
  (add-hook 'text-mode-hook 'copilot-mode) ;;
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "C-TAB") 'copilot-accept-completion-by-word)
  (define-key copilot-completion-map (kbd "C-<tab>") 'copilot-accept-completion-by-word)

  ;; Warningを無効にする設定
  (setq copilot-infer-indentation-offset 'disable)
  (setq copilot--disable-infer-indentation t))
(setq warning-suppress-types '((copilot)))
(setq-default tab-width 4)        ;; タブ幅を4スペースに設定
(setq-default indent-tabs-mode nil) ;; タブではなくスペースを使用
;; 他のAIツールと連携
;; (leaf chatgpt-shell
;;   :ensure t
;;   :custom
;;   (chatgpt-shell-backend . 'chatgpt-shell-openai)
;;   :config
;;   (defun load-chatgpt-shell-key ()
;;     "Load the OpenAI API key only when needed."
;;     (unless chatgpt-shell-openai-key
;;       (let ((key-file "~/.emacs.d/secrets/.openai-key"))
;;         (if (file-exists-p key-file)
;;             (setq chatgpt-shell-openai-key
;;                   (with-temp-buffer
;;                     (insert-file-contents key-file)
;;                     (string-trim (buffer-string))))
;;           (error "APIキーのファイルが見つかりません: %s" key-file)))))
;;   ;; ChatGPT-shell起動時にAPIキーをロード
;;   (add-hook 'chatgpt-shell-mode-hook #'load-chatgpt-shell-key))
;; (leaf chatgpt-shell
;;   :ensure t
;; ;;  :config                               
;;   )
;;
(leaf diff-hl
  :ensure t
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


;; eshell-git-promptの設定
(leaf eshell-git-prompt
  :ensure t
  :config
  (eshell-git-prompt-use-theme 'powerline))



(setq enable-local-variables t)

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

(global-set-key (kbd "<f5>") 'compile)

;; 全角スペースをハイライトする設定
(defface my-full-width-space-face
  '((t (:background "gray20"))) ;; 背景色を変更 (任意の色に変更可能)
  "Face for highlighting full-width spaces.")

(defun my-highlight-full-width-spaces ()
  "Highlight full-width spaces in the buffer."
  (font-lock-add-keywords
   nil
   '(("　" 0 'my-full-width-space-face append))))

(add-hook 'prog-mode-hook 'my-highlight-full-width-spaces) ;; プログラムモードで有効化
(add-hook 'text-mode-hook 'my-highlight-full-width-spaces) ;; テキストモードで有効化
;; 現在開いているファイルのディレクトリにカレントディレクトリを移動する関数
(defun my/set-cwd-to-current-file ()
  "Set the current working directory to the directory of the currently opened file."
  (interactive)
  (if (buffer-file-name)
      (let ((dir (file-name-directory (buffer-file-name))))
        (cd dir)
        (message "Changed current directory to: %s" dir))
    (message "Current buffer is not visiting a file")))

;; ショートカットキーを設定 (例: C-c d)
(global-set-key (kbd "C-c d") 'my/set-cwd-to-current-file)
;;(setq select-enable-clipboard t)
