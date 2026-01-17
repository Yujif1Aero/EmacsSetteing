;; (leaf auctex
;;   :straight t
;;   :ensure t
;;   :config
;;   (setq TeX-auto-save t
;;         TeX-parse-self t
;;         TeX-source-correlate-mode t
;;         TeX-source-correlate-start-server t
;;         TeX-master nil)
;;     (add-to-list 'auto-mode-alist '("\\.tikz\\'" . LaTeX-mode))
;;   ;; AUCTeX 側でも拡張子を認識させる（C-c C-c などが効きやすくなる）
;;     (with-eval-after-load 'tex
;;     (add-to-list 'TeX-file-extensions "tikz")))


;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; AUCTeX設定
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (require 'tex-site)
;; (setq TeX-auto-save t)
;; (setq TeX-parse-self t)
;; (setq-default TeX-master nil)
;; ;; upLaTeX設定
;; (setq japanese-TeX-command-default "upLaTeX")
;; (setq japanese-LaTeX-command-default "upLaTeX")
;; ;; 自動で.synctexファイル生成
;; (setq LaTeX-command "uplatex -kanji=utf8 -synctex=1")
;; ;; inverse search設定
;; (require 'server)
;; (unless (server-running-p)
;;   (server-start))

;; (setq TeX-source-correlate-mode t)
;; (setq TeX-source-correlate-start-server t)
;; ;; コンパイルコマンドのカスタマイズ
;; (eval-after-load 'tex-jp
;;   '(setq TeX-command-list
;;          (append
;;           '(("upLaTeX" "uplatex -kanji=utf8 -guess-input-enc -synctex=1 %`%S%(mode)%' %t"
;;              TeX-run-TeX nil (latex-mode) :help "Run upLaTeX")
;;             ("upBibTeX" "upbibtex %s" TeX-run-BibTeX nil t :help "Run upBibTeX")
;;             ("Dvipdfmx" "dvipdfmx %d" TeX-run-command t t :help "Convert DVI to PDF with dvipdfmx")
;;             ;; 一発でコンパイル→PDF変換するコマンド
;;             ("upLaTeX->PDF" "uplatex -kanji=utf8 -guess-input-enc -synctex=1 %`%S%(mode)%' %t && dvipdfmx %d"
;;              TeX-run-command t (latex-mode) :help "Run upLaTeX and convert to PDF"))
;;           TeX-command-list)))
;; ;; LaTeX-mode設定
;; (add-hook 'LaTeX-mode-hook
;;           (lambda ()
;;             (setq TeX-command-default "upLaTeX")
;;             (setq TeX-PDF-mode nil)))
;; ;; SumatraPDF設定
;; (with-eval-after-load 'tex
;;   (add-to-list 'TeX-view-program-list
;;                '("SumatraPDF" "SumatraPDF -reuse-instance %o -forward-search %b %n"))
;;   (setq TeX-view-program-selection
;;         '((output-pdf "SumatraPDF"))))
;; (with-eval-after-load 'tex-jp
;;   (add-to-list 'TeX-view-program-list
;;                '("SumatraPDF" "SumatraPDF -reuse-instance %o -forward-search %b %n"))
;;   (setq TeX-view-program-selection
;;         '((output-pdf "SumatraPDF"))))
;; ;; 安全版：自動でDVI→PDF変換してから表示
;; ;;; (defun my-latex-compile-and-view ()
;; ;;;   "upLaTeX -> dvipdfmx -> view の自動実行"
;; ;;;   (interactive)
;; ;;;   (save-buffer)  ; バッファを保存
;; ;;;   (let* ((current-file (buffer-file-name));
;; ;;          (file-base (file-name-sans-extension current-file))
;; ;;;          (file-name (file-name-nondirectory current-file))
;; ;;;          (file-base-name (file-name-sans-extension file-name))
;; ;;;          (tex-file file-name)
;; ;;;          (dvi-file (concat file-base ".dvi"))
;; ;;;          (pdf-file (concat file-base ".pdf"))
;; ;;;          (work-directory (file-name-directory current-file)))
;; ;;;    
;; ;;;     ;; 1. upLaTeX実行
;; ;;;     (message "upLaTeX実行中...")
;; ;;;     (let ((default-directory work-directory))
;; ;;;       (shell-command (concat "uplatex -kanji=utf8 -guess-input-enc -synctex=1 "
;; ;;;                             (shell-quote-argument tex-file))))
;; ;;;    
;; ;;;     ;; 2. 非同期でdvipdfmx実行とView（変数をキャプチャ）
;; ;;;     (run-with-timer 3 nil
;; ;;;                     `(lambda ()
;; ;;;                        (let ((default-directory ,work-directory))
;; ;;;                          (if (file-exists-p ,dvi-file)
;; ;;;                              (progn
;; ;;;                                (message "PDF変換中...")
;; ;;;                                (shell-command (concat "dvipdfmx " (shell-quote-argument ,dvi-file)))
;; ;;;                                ;; PDF変換後にView
;; ;;;                                (run-with-timer 2 nil
;; ;;;                                                `(lambda ()
;; ;;;                                                   (if (file-exists-p ,pdf-file)
;; ;;;                                                       (progn
;; ;;;                                                         (message "PDFを表示中...")
;; ;;;                                                         (start-process "SumatraPDF" nil "SumatraPDF" "-reuse-instance" ,pdf-file))
;; ;;;                                                     (message "PDFファイルの生成に失敗しました")))))
;; ;;;                            (message "DVIファイルの生成に失敗しました"))))))
;; ;;;
;; ;; より安全な版：変数スコープの問題を完全回避
;; (defun my-latex-compile-and-view-safer ()
;;   "upLaTeX -> dvipdfmx -> view の自動実行（より安全版）"
;;   (interactive)
;;   (save-buffer)
;;   (let* ((current-file (buffer-file-name))
;;          (work-directory (file-name-directory current-file))
;;          (file-name (file-name-nondirectory current-file)))
;;     ;; 1. upLaTeX実行
;;     (message "upLaTeX実行中...")
;;     (let ((default-directory work-directory))
;;       (shell-command (concat "uplatex -kanji=utf8 -guess-input-enc -synctex=1 "
;;                             (shell-quote-argument file-name))))
;;     ;; 2. 同期処理版（タイマーを使わない）
;;     (sit-for 3)  ; 3秒待機
;;     (let* ((file-base (file-name-sans-extension current-file))
;;            (dvi-file (concat file-base ".dvi"))
;;            (pdf-file (concat file-base ".pdf"))
;;            (default-directory work-directory))
;;       (if (file-exists-p dvi-file)
;;           (progn
;;             (message "PDF変換中...")
;;             (shell-command (concat "dvipdfmx " (shell-quote-argument dvi-file)))
;;             (sit-for 2)  ; 2秒待機
;;             (if (file-exists-p pdf-file)
;;                 (progn
;;                   (message "PDFを表示中...")
;;                   (start-process "SumatraPDF" nil "SumatraPDF" "-reuse-instance" pdf-file))
;;               (message "PDFファイルの生成に失敗しました")))
;;         (message "DVIファイルの生成に失敗しました")))))
;; ;; 安全版：手動でDVI→PDF変換する関数
;; (defun my-dvi-to-pdf ()
;;   "現在のDVIファイルをPDFに変換"
;;   (interactive)
;;   (let* ((current-file (buffer-file-name))
;;          (file-base (file-name-sans-extension current-file))
;;          (dvi-file (concat file-base ".dvi"))
;;          (default-directory (file-name-directory current-file)))
;;     (if (file-exists-p dvi-file)
;;         (progn
;;           (message "DVI→PDF変換中...")
;;           (shell-command (concat "dvipdfmx " (shell-quote-argument dvi-file)))
;;           (message "DVI→PDF変換が完了しました"))
;;       (message "DVIファイルが見つかりません"))))
;; ;; PDFを表示する関数
;; (defun my-sumatra-view ()
;;   "SumatraPDFで直接PDFを開く"
;;   (interactive)
;;   (let* ((current-file (buffer-file-name))
;;          (file-base (file-name-sans-extension current-file))
;;          (pdf-file (concat file-base ".pdf")))
;;     (if (file-exists-p pdf-file)
;;         (start-process "SumatraPDF" nil "SumatraPDF" "-reuse-instance" pdf-file)
;;       (message "PDFファイルが見つかりません"))))
;; ;; upLaTeX単体実行関数
;; (defun my-uplatex-compile ()
;;   "upLaTeXのみ実行"
;;   (interactive)
;;   (save-buffer)
;;   (let* ((current-file (buffer-file-name))
;;          (file-name (file-name-nondirectory current-file))
;;          (default-directory (file-name-directory current-file)))
;;     (message "upLaTeX実行中...")
;;     (shell-command (concat "uplatex -kanji=utf8 -guess-input-enc -synctex=1 "
;;                           (shell-quote-argument file-name)))
;;     (message "upLaTeX完了")))
;; ;; キーバインド設定
;; (add-hook 'LaTeX-mode-hook
;;           (lambda ()
;;             (define-key LaTeX-mode-map (kbd "C-c C-a") 'my-latex-compile-and-view-safer)
;;             (define-key LaTeX-mode-map (kbd "C-c C-p") 'my-dvi-to-pdf)
;;             (define-key LaTeX-mode-map (kbd "C-c C-v") 'my-sumatra-view)
;;             (define-key LaTeX-mode-map (kbd "C-c C-u") 'my-uplatex-compile)))
;; ;; Forward search用関数
;; (defun my-forward-search ()
;;   "Forward search: EmacsからSumatraPDFの対応箇所にジャンプ"
;;   (interactive)
;;   (let* ((current-file (buffer-file-name))
;;          (file-base (file-name-sans-extension current-file))
;;          (pdf-file (concat file-base ".pdf"))
;;          (tex-file (file-name-nondirectory current-file))
;;          (line-number (line-number-at-pos)))
;;     (if (file-exists-p pdf-file)
;;         (start-process "SumatraPDF-forward" nil "SumatraPDF"
;;                        "-reuse-instance" pdf-file
;;                        "-forward-search" tex-file (number-to-string line-number))
;;       (message "PDFファイルが見つかりません"))))
;; ;; キーバインド追加
;; (add-hook 'LaTeX-mode-hook
;;           (lambda ()
;;             (define-key LaTeX-mode-map (kbd "C-c C-f") 'my-forward-search)))
;; ;; verbatim環境の読みやすい設定
;; (eval-after-load 'font-latex
;;   '(progn
;;      ;; verbatim環境を標準フォントに（色は少し変える）
;;      (custom-set-faces
;;       '(font-latex-verbatim-face
;;         ((t (:inherit default :foreground "DarkGreen"))))
;;       '(font-latex-verb-face
;;         ((t (:inherit default :foreground "DarkGreen")))))))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;; End of File
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; -*- coding: utf-8 -*-
;;; tex.el --- AUCTeX with Synctex support for WSL2



;;; -*- coding: utf-8 -*-
;;; tex.el --- AUCTeX setup
;; (leaf auctex
;;   :straight t
;;   :custom
;;   ((TeX-auto-save . t)
;;    (TeX-parse-self . t)
;;    (TeX-master . nil)
;;    (TeX-PDF-mode . t)
;;    (TeX-source-correlate-mode . t)
;;    (TeX-source-correlate-start-server . t)
;;    (TeX-command-default . "Latexmk"))

;;   :config
;;   ;; 1. 共通のビルドコマンド (Latexmk)
;;   (with-eval-after-load 'tex
;;     (add-to-list 'TeX-command-list
;;                  '("Latexmk" "latexmk -pdf -pdflatex='pdflatex -shell-escape -synctex=1 -interaction=nonstopmode' %t"
;;                    TeX-run-TeX nil (latex-mode) :help "Run Latexmk")))

;;   ;; 2. 環境に応じたビューアとジャンプ設定
;;   (cond
;;    ;; --- WSL2 の場合 (SumatraPDFを使用) ---
;;    ((and (fboundp 'running-in-wsl-p) (running-in-wsl-p))
;;     (with-eval-after-load 'tex
;;       (add-to-list 'TeX-view-program-list
;;                    '("SumatraPDF" 
;;                      "powershell.exe -NoProfile -Command SumatraPDF.exe -reuse-instance -forward-search %b %n (wslpath -w %o)"))
;;       (setq TeX-view-program-selection '((output-pdf "SumatraPDF"))))
;;     ;; Emacsサーバー起動（逆引き用）
;;     (require 'server)
;;     (unless (server-running-p) (server-start)))

;;    ;; --- 純粋な Linux (GUI) の場合 ---
;;    ((eq system-type 'gnu/linux)
;;     ;; 内部ビューア pdf-tools を優先的に使用
;;     (leaf pdf-tools
;;       :straight t
;;       :config
;;       (pdf-tools-install)
;;       (setq-default pdf-view-display-size 'fit-width)
;;       (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))
    
;;     (with-eval-after-load 'tex
;;       (add-to-list 'TeX-view-program-list '("pdf-tools" "TeX-pdfview-sync-view"))
;;       (setq TeX-view-program-selection '((output-pdf "pdf-tools"))))
    
;;     ;; 保存時に自動コンパイルしたい場合は以下を有効に
;;     ;; (add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
;;     ))

;;   :hook
;;   (LaTeX-mode-hook . (lambda ()
;;                        (LaTeX-math-mode t)
;;                        (local-set-key (kbd "C-c C-g") 'TeX-view))))

;; ;; 文献管理
;; (leaf reftex
;;   :straight t
;;   :hook (LaTeX-mode-hook . turn-on-reftex)
;;   :custom ((reftex-plug-into-AUCTeX . t)))

;;; -*- coding: utf-8 -*-

(leaf auctex
  :straight t
  :custom
  ((TeX-auto-save . t)
   (TeX-parse-self . t)
   (TeX-master . nil) ; 親ファイルを聞く設定
   (TeX-PDF-mode . t)
   (TeX-source-correlate-mode . t)
   (TeX-source-correlate-method . 'synctex)
   (TeX-source-correlate-start-server . t)
   (TeX-command-default . "Latexmk"))

  :config
  ;; --- TikZ/PGFPlots 色付けの究極強化 ---
  (add-to-list 'auto-mode-alist '("\\.tikz\\'" . LaTeX-mode))
  
  (defun my/latex-tikz-font-lock-setup ()
    "TikZとPGFPlotsのコードをOverleaf以上に鮮やかにします。"
    (font-lock-add-keywords 
     nil
     '(;; 1. コマンド (draw, node, addplot, coordinatesなど)
       ("\\\\\\(draw\\|node\\|fill\\|filldraw\\|path\\|coordinate\\|clip\\|shade\\|foreach\\|addplot\\|addlegendentry\\|useasboundingbox\\)\\>" 1 font-lock-keyword-face)
       ;; 2. 構造 (axis, tikzpicture, scope, legend, plotなど)
       ("\\b\\(tikzpicture\\|axis\\|scope\\|at\\|cycle\\|node\\|child\\|style\\|plot\\|coordinates\\|legend\\|xlabel\\|ylabel\\|xmin\\|xmax\\|ymin\\|ymax\\|xtick\\|ytick\\|domain\\|samples\\)\\b" 0 font-lock-function-name-face)
       ;; 3. 演算子 (-- , ++, -|, |-, ..)
       ("--\\|\\+\\+\\|\\.\\.\\||-\\|-|" 0 font-lock-constant-face)
       ;; 4. 特殊記号とオプション
       ("\\[\\|\\]" 0 font-lock-warning-face)
       ("{" 0 font-lock-variable-name-face)
       ("}" 0 font-lock-variable-name-face)
       ;; 5. 数式 ($...$)
       ("\\$.*?\\$" 0 font-lock-string-face))))

  (add-hook 'LaTeX-mode-hook #'my/latex-tikz-font-lock-setup)

  (with-eval-after-load 'tex
    (add-to-list 'TeX-file-extensions "tikz")
    (setq TeX-view-program-list '(("pdf-tools" "TeX-pdfview-sync-view")))
    (setq TeX-view-program-selection '((output-pdf "pdf-tools")))
    (add-to-list 'TeX-command-list
                 '("Latexmk" "latexmk -pdf -pdflatex='pdflatex -shell-escape -synctex=1 -interaction=nonstopmode' %t"
                   TeX-run-TeX nil (latex-mode) :help "Run Latexmk")))

  ;; コンパイル後の自動更新（Bad file descriptor 対策）
  (add-hook 'TeX-after-compilation-finished-functions
            (lambda (file)
              (let ((pdf-buffer (find-buffer-visiting file)))
                (when (and pdf-buffer (buffer-live-p pdf-buffer))
                  (run-with-timer 1.2 nil 
                                  (lambda (buf) (when (buffer-live-p buf) (with-current-buffer buf (ignore-errors (pdf-view-revert-buffer)))))
                                  pdf-buffer)))))
  :hook
  (LaTeX-mode-hook . (lambda ()
                       (TeX-source-correlate-mode t)
                       (LaTeX-math-mode t)
                       ;; --- 【重要】C-c C-g を直接 pdf-sync-forward-search にバインド ---
                       (local-set-key (kbd "C-c C-g") (lambda () (interactive) (pdf-sync-forward-search))))))

(leaf pdf-tools
  :straight t
  :config
  (setq pdf-info-process-timeout 30)
  (setq pdf-info-restart-process-p t)
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
  (add-hook 'pdf-view-mode-hook #'pdf-sync-minor-mode)
  (setq pdf-view-midnight-colors '("#ebdbb2" . "#282828")))
