;初回時画面起動させない
(setq inhibit-startup-message t)

;;; ------ Startup definitions for YaTeX Original Yuji SHIMOJIMA ------ ;;;
  (setq auto-mode-alist
    (cons (cons "\.tex$" 'yatex-mode) auto-mode-alist))
  (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
  (add-to-list 'load-path "/Applications/Emacs.app/Contents/Resources/share//Applications/Emacs.app/Contents/MacOS/Emacs/site-lisp/yatex")
  (setq YaTeX-help-file "/Applications/Emacs.app/Contents/Resources/share//Applications/Emacs.app/Contents/MacOS/Emacs/site-lisp/yatex/help/YATEXHLP.eng")
  (setq tex-command "platex")
  (setq dvi2-command "xdvi")
  (setq tex-pdfview-command "acroread")
  (setq bibtex-command "jbibtex")
;; ;Bibtex fix
(add-hook 'yatex-mode-hook 'turn-on-reftex)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ------ Startup definitions for YaTeX ------ ;;;
;; (setq auto-mode-alist
;;   (cons (cons "\.tex$" 'yatex-mode) auto-mode-alist))
;; (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
;; (add-to-list 'load-path "/Applications/Emacs.app/Contents/Resources/site-lisp/yatex")
;; (setq YaTeX-help-file "/Applications/Emacs.app/Contents/Resources/site-lisp/yatex/help/YATEXHLP.eng")
;; (setq tex-command "platex")
;; (setq dvi2-command "xdvi")
;; (setq tex-pdfview-command "acroread")
;;; ------------------------------------------- ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;20180715
;https://texwiki.texjp.org/?YaTeX
;;
;; PATH
;;
;(setenv "PATH" "/usr/local/bin:/Library/TeX/texbin/:/Applications/Skim.app/Contents/SharedSupport:$PATH" t)
;(setq exec-path (append '("/usr/local/bin" "/Library/TeX/texbin" "/Applications/Skim.app/Contents/SharedSupport") exec-path))

;;
;; YaTeX
;;
;; (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
;; (setq auto-mode-alist
;;       (append '(("\\.tex$" . yatex-mode)
;;                 ("\\.ltx$" . yatex-mode)
;;                 ("\\.cls$" . yatex-mode)
;;                 ("\\.sty$" . yatex-mode)
;;                 ("\\.clo$" . yatex-mode)
;;                 ("\\.bbl$" . yatex-mode)) auto-mode-alist))
;; (setq YaTeX-inhibit-prefix-letter t)
;; (setq YaTeX-kanji-code nil)
;; (setq YaTeX-latex-message-code 'utf-8)
;; (setq YaTeX-use-LaTeX2e t)
;; (setq YaTeX-use-AMS-LaTeX t)
;; (setq YaTeX-dvi2-command-ext-alist
;;       '(("TeXworks\\|texworks\\|texstudio\\|mupdf\\|SumatraPDF\\|Preview\\|Skim\\|TeXShop\\|evince\\|atril\\|xreader\\|okular\\|zathura\\|qpdfview\\|Firefox\\|firefox\\|chrome\\|chromium\\|MicrosoftEdge\\|microsoft-edge\\|Adobe\\|Acrobat\\|AcroRd32\\|acroread\\|pdfopen\\|xdg-open\\|open\\|start" . ".pdf")))
;; (setq tex-command "ptex2pdf -u -l -ot '-synctex=1'")
;; ;(setq tex-command "lualatex -synctex=1")
;; ;(setq tex-command "latexmk")
;; ;(setq tex-command "latexmk -e '$latex=q/uplatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
;; ;(setq tex-command "latexmk -e '$lualatex=q/lualatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -norc -gg -pdflua")
;; (setq bibtex-command "latexmk -e '$latex=q/uplatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
;; (setq makeindex-command "latexmk -e '$latex=q/uplatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
;; ;(setq dvi2-command "open -a Skim")
;; (setq dvi2-command "open -a Preview")
;; ;(setq dvi2-command "open -a TeXShop")
;; ;(setq dvi2-command "/Applications/TeXworks.app/Contents/MacOS/TeXworks")
;; ;(setq dvi2-command "/Applications/texstudio.app/Contents/MacOS/texstudio --pdf-viewer-only")
;; ;(setq tex-pdfview-command "open -a Skim")
;; (setq tex-pdfview-command "open -a Preview")
;; ;(setq tex-pdfview-command "open -a TeXShop")
;; ;(setq tex-pdfview-command "/Applications/TeXworks.app/Contents/MacOS/TeXworks")
;; ;(setq tex-pdfview-command "/Applications/texstudio.app/Contents/MacOS/texstudio --pdf-viewer-only")
;; (setq dviprint-command-format "open -a \"Adobe Acrobat Reader DC\" `echo %s | gsed -e \"s/\\.[^.]*$/\\.pdf/\"`")

;; (add-hook 'yatex-mode-hook
;;           '(lambda ()
;;              (auto-fill-mode -1)))

;; ;;
;; ;; RefTeX with YaTeX
;; ;;
;; ;(add-hook 'yatex-mode-hook 'turn-on-reftex)
;; (add-hook 'yatex-mode-hook
;;           '(lambda ()
;;              (reftex-mode 1)
;;              (define-key reftex-mode-map (concat YaTeX-prefix ">") 'YaTeX-comment-region)
;;              (define-key reftex-mode-map (concat YaTeX-prefix "<") 'YaTeX-uncomment-region)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;
;;;emacs seting
(global-linum-mode t)
(electric-pair-mode 1)
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(global-hl-line-mode t)
(show-paren-mode 1)
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

;(set-face-background 'show-paren-match-face "red") 
;(set-face-foreground 'show-paren-match-face "black")
(show-paren-mode 1)
(set-language-environment "Japanese")
(global-linum-mode t)
;(set-face-background 'default "black")
;(set-face-foreground 'default "green")

; windmove
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <right>") 'windmove-right)

;; Macでoptionをmetaに設定
;; OptionキーをMetaキーに割り当て
(when (equal system-type 'darwin)
  (setq mac-option-modifier 'meta) ;; 左OptionをMetaに設定
  (setq mac-right-option-modifier nil)) ;; 右Optionを通常のOptionとして保持

;;---------emacs でコピーしたものを他のアプリでも使用可能にする
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)

(cond (window-system
(setq x-select-enable-clipboard t)
))

;;日本語の設定
;https://utsuboiwa.blogspot.com/2014/07/sunnyside-emacs.html
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)


(defun copy-from-osx ()
(shell-command-to-string "pbpaste"))
(defun paste-to-osx (text &optional push)
(let ((process-connection-type nil))
(let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
(process-send-string proc text)
(process-send-eof proc))))



(add-to-list 'default-frame-alist '(cursor-type . bar))


(setq auto-mode-alist (cons '("\\.cu$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cuh$" . c++-mode) auto-mode-alist))


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

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(lua-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
