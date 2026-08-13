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
    ;; pdf-tools のビューアは「関数シンボル」で指定する。
    ;; 文字列にすると AUCTeX がシェルコマンドとして実行してしまい（該当コマンドは
    ;; 存在しないので）何も表示されない。正しい関数は TeX-pdf-tools-sync-view。
    (setq TeX-view-program-list '(("pdf-tools" TeX-pdf-tools-sync-view)))
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
  ;; 通信安定化
  (setq pdf-info-process-timeout 30)
  (setq pdf-info-restart-process-p t)

  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)

  ;; --- 【変更】拡大縮小を有効にする ---
  ;; .wslgconfig の設定が済んでいれば t にして大丈夫です
  (setq pdf-view-use-scaling t)

  ;; --- 【追加】マウスホイールでの拡大縮小設定 ---
  (with-eval-after-load 'pdf-view
    ;; Ctrl + ホイール上下で拡大縮小
    (define-key pdf-view-mode-map (kbd "<C-wheel-up>") 'pdf-view-enlarge)
    (define-key pdf-view-mode-map (kbd "<C-wheel-down>") 'pdf-view-shrink)
    ;; また、通常のホイールでも拡大縮小したい場合は以下も追加
    ;; (define-key pdf-view-mode-map [wheel-up] 'pdf-view-enlarge)
    ;; (define-key pdf-view-mode-map [wheel-down] 'pdf-view-shrink)
    )

  ;; 行番号表示の競合回避
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
  (add-hook 'pdf-view-mode-hook #'pdf-sync-minor-mode)

  (setq pdf-view-midnight-colors '("#ebdbb2" . "#282828"))

  ;; --- VS Code 風レイアウト: PDF は常に右側のウィンドウに表示する ---
  ;; ソース(tex)を左、PDF を右に固定し、コンパイル時に上下分割にならないようにする。
  (add-to-list 'display-buffer-alist
               '("\\.pdf\\'"
                 (display-buffer-reuse-window display-buffer-in-side-window)
                 (side . right)
                 (window-width . 0.5)
                 (reusable-frames . visible)))
  ;; 幅が広い時に AUCTeX のバッファ分割も左右優先にする
  (setq split-height-threshold nil
        split-width-threshold 120))

;;; --- Spell check (flyspell + aspell) ------------------------------------
;; 要 aspell 本体（未導入なら ~/restore-spell.sh を実行）。
(with-eval-after-load 'ispell
  (setq ispell-program-name (or (executable-find "aspell") "aspell")
        ispell-dictionary "en_US"
        ispell-extra-args '("--sug-mode=ultra")))
;; LaTeX/テキストは本文をスペルチェック、コードはコメント/文字列のみ
(add-hook 'LaTeX-mode-hook #'flyspell-mode)
(add-hook 'text-mode-hook  #'flyspell-mode)
(add-hook 'prog-mode-hook  #'flyspell-prog-mode)
;; C-; は他機能と衝突しやすいので、修正候補は C-c $ / M-$ を使う想定

;;; --- Overleaf ------------------------------------------------------------
;; overleaf.el(リアルタイム同期)は使わない方針に変更。
;; Overleaf は Git bridge でプロジェクトを clone し、magit で pull/push 運用する。
;; 手順は README.md「5. Overleaf (Git bridge)」を参照。

;;; --- LTeX: 文法・文体チェック（LanguageTool ベース, オフライン） -----------
;; 本体は git 外に配置（~/ltex_installer.sh 相当の ltex_installer.sh で導入）。
;; Eglot(標準搭載) から ltex-ls-plus をローカル起動する。
(defvar my/ltex-ls-dir
  (expand-file-name ".local/opt/ltex-ls-plus-18.7.0" "~")
  "ltex-ls-plus を展開したディレクトリ。バージョンを上げたらここも更新する。")

(with-eval-after-load 'eglot
  (let ((ltex-bin (expand-file-name "bin/ltex-ls-plus" my/ltex-ls-dir)))
    (when (file-executable-p ltex-bin)
      (add-to-list 'eglot-server-programs
                   `((latex-mode LaTeX-mode plain-tex-mode context-mode)
                     . (,ltex-bin))))))

;; 文法チェックしたいバッファで手動起動: M-x eglot
;; （JVM 起動が重いので自動起動はしない。常時ONにしたい場合は下を有効化）
;; (add-hook 'LaTeX-mode-hook #'eglot-ensure)
;;
;; 言語や辞書はプロジェクトごとに .dir-locals.el で上書き可能:
;;   ((latex-mode . ((eglot-workspace-configuration
;;     . (:ltex (:language "en-US"))))))

;;; --- latexindent: 手動整形コマンド（TeX / TikZ 用） -------------------------

(defgroup my-latexindent nil
  "Run latexindent on current buffer/region."
  :group 'tex)

(defcustom my/latexindent-command
  (or (executable-find "latexindent")
      (executable-find "latexindent.pl")
      (executable-find "latexindent.exe"))
  "latexindent command name/path."
  :type 'string)

(defun my/latexindent--null-device ()
  (if (eq system-type 'windows-nt) "NUL" "/dev/null"))

(defun my/latexindent--local-settings-arg ()
  "同じフォルダに localSettings.yaml があればそれを使う。無ければ nil。"
  (let* ((dir (or (and buffer-file-name (file-name-directory buffer-file-name))
                  default-directory))
         (yaml (expand-file-name "localSettings.yaml" dir)))
    (when (file-exists-p yaml)
      (concat "-l=" yaml))))

(defun my/latexindent--cmd ()
  "latexindent 実行コマンド文字列（STDIN 用に最後は '-'）。"
  (unless my/latexindent-command
    (user-error "latexindent が見つかりません。TeX Live/MiKTeX などを確認して `latexindent -v` を試してみてください"))
  ;; -g /dev/null で indent.log を作らない（作れなければログ無しで動く）:contentReference[oaicite:3]{index=3}
  (let* ((local (my/latexindent--local-settings-arg))
         (parts (delq nil
                      (list my/latexindent-command
                            "-g" (my/latexindent--null-device)
                            ;; localSettings.yaml があれば使う（STDIN でもOK。最後は '-' が必要）:contentReference[oaicite:4]{index=4}
                            local
                            "-"))))
    (mapconcat #'identity parts " ")))

(defun my/latexindent-region (beg end)
  "選択範囲を latexindent に通して置き換え、タブ→スペース & 行末空白も掃除する。"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (let* ((mbeg (copy-marker beg))
         (mend (copy-marker end t))
         (errbuf (get-buffer-create "*latexindent errors*"))
         (cmd (my/latexindent--cmd))
         (p (point))
         (w (window-start)))
    (with-current-buffer errbuf (erase-buffer))
    ;; latexindent 実行（あなたの既存実装に合わせて shell-command-on-region を使う例）
    (shell-command-on-region mbeg mend cmd (current-buffer) t errbuf t)

    ;; --- ここが追加：タブ→スペース、行末空白削除 ---
    (let ((b (marker-position mbeg))
          (e (marker-position mend)))
      ;; タブをスペースに（tab-width 分のスペースになる）
      (let ((indent-tabs-mode nil))   ; 念のため
        (untabify b e))
      ;; コメント行も含めて行末空白を消す
      (delete-trailing-whitespace b e))

    (goto-char (min p (point-max)))
    (set-window-start (selected-window) w)
    (set-marker mbeg nil)
    (set-marker mend nil)))

(defun my/latexindent-buffer ()
  "バッファ全体を latexindent に通す。"
  (interactive)
  (my/latexindent-region (point-min) (point-max)))

;; TeX / LaTeX / TikZ で同じショートカットにする（あなたの C-c /, C-c C-_ に合わせる）
(with-eval-after-load 'tex
  (add-hook 'TeX-mode-hook
            (lambda ()
              (local-set-key (kbd "C-c /")   #'my/latexindent-buffer)
              (local-set-key (kbd "C-c C-_") #'my/latexindent-region))))

;; --- latex-mode (Emacs標準) 側でもキーを上書きする ---
(with-eval-after-load 'tex-mode
  (define-key latex-mode-map (kbd "C-c /")   #'my/latexindent-buffer)
  (define-key latex-mode-map (kbd "C-c C-_") #'my/latexindent-region)
  ;; 環境によって C-_ が入りにくい保険
  (define-key latex-mode-map (kbd "C-c C-/") #'my/latexindent-region))

;;; --- 必ず AUCTeX の LaTeX-mode を使う（標準 latex-mode を避ける） -----------
;; init.el はこのファイルを起動の約1秒後に読み込むため、コマンドライン
;; (emacs main.tex) で開いた .tex は先に組み込みの `latex-mode` で開かれてしまい、
;; C-c C-a (TeX-command-run-all) が "undefined" になる。
;; 1) 今後開く .tex は latex-mode → LaTeX-mode に自動で載せ替える。
(add-to-list 'major-mode-remap-alist '(latex-mode . LaTeX-mode))
;; 2) すでに標準 latex-mode で開いているバッファを AUCTeX へ切り替える。
(dolist (buf (buffer-list))
  (with-current-buffer buf
    (when (eq major-mode 'latex-mode)
      (LaTeX-mode))))

;;; --- 端末(-nw)での C-c C-a: 外部ビューアで表示＋完了メッセージ ------------
;; -nw では pdf-tools が PDF を画像描画できず「文字列」になってしまう。
;; そこで端末フレームでは evince で開き、GUI フレームでは従来どおり pdf-tools。
;; evince はファイル変更を自動再読込するので、同じ PDF の evince が
;; まだ無いときだけ起動する（毎回ウィンドウが増えないように）。
(with-eval-after-load 'tex
  ;; evince はファイル変更を自動再読込するので、同じ PDF の evince が
  ;; まだ無いときだけ起動する（毎回ウィンドウが増えないように）。
  ;; 判定は「プロセス名が正確に evince のものだけ」を対象にする（pgrep -ax evince）。
  ;; pgrep -f だとラッパの sh -c '...evince %o...' 自身にマッチしてしまい、
  ;; 常に「起動済み」と誤判定して evince が開かないので注意。
  (add-to-list 'TeX-view-program-list
               '("evince-reuse"
                 "sh -c 'f=%o; b=$(basename \"$f\"); pgrep -ax evince 2>/dev/null | grep -Fq \"$b\" || (evince \"$f\" >/dev/null 2>&1 &)'"))
  ;; 【重要】TeX-view-program-selection の条件は「TeX-view-predicate-list に
  ;; 登録した述語名」でなければ評価されない（任意の関数名は不可。AUCTeX は
  ;; 名前に対応する式を eval する）。現在のフレームが非グラフィカルかを判定する
  ;; 述語 frame-not-graphic を登録して、その名前を selection で使う。
  (add-to-list 'TeX-view-predicate-list
               '(frame-not-graphic (not (display-graphic-p))))
  ;; 端末(-nw)フレームなら evince、GUI フレームなら pdf-tools。
  (setq TeX-view-program-selection
        '(((output-pdf frame-not-graphic) "evince-reuse")
          (output-pdf "pdf-tools"))))

;; C-c C-a / C-c C-c の既定コンパイラを latexmk にする。
;; TeX-command-default はバッファローカル変数で、mode 初期化時に "LaTeX" 等へ
;; セットされるため :custom では確実に効かない。LaTeX-mode-hook で毎回上書きする。
;; TeX-command-run-all(C-c C-a) は再コンパイルが必要なとき、この変数の値を実行する
;; ので、これで C-c C-a が latexmk（差分ビルド＋必要な回数・bibtex を自動）になる。
(add-hook 'LaTeX-mode-hook
          (lambda () (setq TeX-command-default "Latexmk")))

;; コンパイル完了を知らせる（GUI / 端末どちらでも）。
;; TeX-command-run-all(C-c C-a) はビルド後に上記ビューアで PDF を開く。
;; フレーム種別に応じて文言を変える:
;;   GUI    → pdf-tools が右側に描画
;;   端末   → evince で開く/更新
(defun my/tex-notify-compile-finished (file)
  "コンパイル結果をエコーエリアに表示する。
AUCTeX / latexmk はビルド失敗時（例: パッケージ未検出の Fatal error）でも
このフックを呼ぶことがあり、TeX-error-list が空のまま「成功」と誤認する。
そこでフックの呼び出しを信用せず、PDF が実際に生成・更新されたか
（存在する＋直近 20 秒以内に更新された）を独自に検証し、
本当に成功したときだけ ✅、そうでなければ ❌ を表示する。"
  (when (and file (string-match-p "\\.pdf\\'" file))
    (let* ((attrs  (file-attributes file))
           (mtime  (and attrs (nth 5 attrs)))
           ;; 今回のビルドで生成されたなら mtime はほぼ現在時刻になる。
           (fresh  (and mtime (< (float-time (time-since mtime)) 20)))
           ;; AUCTeX がエラーを拾えていれば失敗確定。
           (has-errors
            (ignore-errors
              (with-current-buffer (if (and (boundp 'TeX-command-buffer)
                                            (buffer-live-p TeX-command-buffer))
                                       TeX-command-buffer
                                     (current-buffer))
                (and (boundp 'TeX-error-list) TeX-error-list)))))
      (if (and fresh (not has-errors))
          (message "✅ コンパイル完了 — %s を%s"
                   (file-name-nondirectory file)
                   (if (display-graphic-p)
                       "pdf-tools で右側に更新表示しました"
                     "更新して evince で開きました"))
        (message "❌ コンパイル失敗 — %s は更新されませんでした（C-c C-l でログ / *TeX Help* を確認）"
                 (file-name-nondirectory file))))))
(add-hook 'TeX-after-compilation-finished-functions
          #'my/tex-notify-compile-finished)

