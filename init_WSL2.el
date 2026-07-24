;;; -*- coding: utf-8 -*-
;;; init_WSL2.el --- WSL2専用設定（高速化版）

;; 【修正】遅延の原因 である powershell.exe の呼び出しを削除しました。
;; 共通設定に統合された OSC 52 方式が、プロセスなしで爆速コピペを行います。

(leaf eshell-git-prompt
  :straight t
  :require t
  :config
  ;; 'powerline はパワーライン専用記号を使うため、それを含まないフォント
  ;; (DejaVu Sans Mono 等)では豆腐に化ける。記号を使わない 'simple にする。
  ;; 他候補: 'default 'robyrussell 'multiline 'git-radar。
  ;; どうしても 'powerline を使いたい場合は Nerd Font 系の導入が必要。
  (when (fboundp 'eshell-git-prompt-use-theme)
    (eshell-git-prompt-use-theme 'git-radar)))

(with-eval-after-load 'magit
  (setenv "GIT_EDITOR" "notepad.exe")
  (setq magit-git-global-arguments
        (append magit-git-global-arguments '("-c" "core.editor=notepad.exe"))))

;; --- クリップボード連携 ---
;; WSLg が X の CLIPBOARD を Windows のクリップボードへ橋渡しするので、標準連携を有効化する。
;; → C-y で Windows から貼り付け、キル/ヤンクも Windows クリップボードと同期する。
;; 注意: このマシンは `emacs --daemon' で動くため、(display-graphic-p) で分岐すると
;; デーモン起動時(GUIフレーム無し)に端末用の無効化側が走ってしまう(=キルリング優先の原因)。
;; これらはグローバル変数なので、GUI 前提で無条件に有効化する。
;; 端末(-nw)だけで使いたい場合のみ明示コピー(C-c c / OSC52)を利用する。
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; GUI (X) フレームでのみ xclip を使う。端末フレームでは走らせない。
(when (display-graphic-p)
  (leaf xclip
    :require t
    :straight t
    :config
      (xclip-mode 1)))


(setq interprogram-paste-function #'gui-selection-value)
;; clipetty は interprogram-cut-function を :around でラップし、内部で必ず
;; (funcall orig-fun string) と元の関数へ委譲する(clipetty.el:166)。
;; 既定が nil だと「Symbol's function definition is void: nil」で落ちるため、
;; 標準の gui-select-text を明示して常に非 nil にしておく。
;; (GUI では X クリップボードへ、端末では clipetty が OSC52 送出後に no-op で委譲)
(setq interprogram-cut-function #'gui-select-text)
(setq frame-resize-pixelwise t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; 日本語入力・表示時の既定コーディングを UTF-8 に統一
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;; --- GUI フォント/UI 設定 ---
;; このマシンは `emacs --daemon' で動作し、フレームは emacsclient で開く。
;; その場合 `window-setup-hook' はデーモン起動時(GUIフレーム無し)に1回発火するだけで、
;; 後から emacsclient でフレームを開いても発火しない。→ フォント設定が丸ごとスキップされる。
;; そこでフレーム作成ごとに走る `after-make-frame-functions' で適用する。
;; フォントサイズは :height(1/10 pt)。170 ≒ 従来 113 の約1.5倍。
(defvar my/latin-font-height 170 "英字 default フェイスのサイズ(1/10 pt)。")
(defun my/setup-gui-frame (&optional frame)
  "GUI フレーム FRAME にフォントと UI を設定する。"
  (when (display-graphic-p frame)
    (let ((frame (or frame (selected-frame))))
      (set-scroll-bar-mode nil)
      (set-fringe-mode 8)
      ;; クリップボード連携をこの GUI フレームで確実に有効化する。
      ;; (デーモン起動時の端末用ブロックが nil に潰すことがあるため、ここで上書きする)
      (setq select-enable-clipboard t
            select-enable-primary t
            interprogram-paste-function #'gui-selection-value
            interprogram-cut-function #'gui-select-text)
      ;; 英字(default): 等幅フォントを優先順に選ぶ。
      ;; フォールバック任せだと HackGen 未インストール環境で Tlwg Typist(タイ語用)に
      ;; 落ちて見づらくなるため、Linux ネイティブで綺麗な DejaVu Sans Mono を第一候補にする。
      ;; NOTE: font-family-list は対象 FRAME を渡さないと、after-make-frame-functions 実行時に
      ;; selected-frame がデーモンのヘッドレスフレームを指し、GUI フォント一覧を返さない。
      (let ((latin-font (seq-find (lambda (f) (member f (font-family-list frame)))
                                  '("HackGen Console NF" "DejaVu Sans Mono"
                                    "Cascadia Mono"))))
        (when latin-font
          (set-face-attribute 'default frame
                              :family latin-font
                              :height my/latin-font-height)))
      ;; 日本語: Meiryo 優先。
      (let ((jp-font (seq-find (lambda (f) (member f (font-family-list frame)))
                               '("Meiryo" "Noto Sans CJK JP" "Noto Sans JP"
                                 "BIZ UDGothic" "Yu Gothic"))))
        (when jp-font
          (dolist (charset '(japanese-jisx0208 japanese-jisx0212
                             katakana-jisx0201 kana han cjk-misc symbol))
            (set-fontset-font t charset (font-spec :family jp-font)))))
      ;; 絵文字
      (unless (eq system-type 'darwin)
        (set-fontset-font t '(#x1F000 . #x1FAFF)
                          (font-spec :name "Noto Color Emoji") nil 'append)))))

(add-hook 'after-make-frame-functions #'my/setup-gui-frame) ; デーモン+emacsclient 用
(add-hook 'window-setup-hook #'my/setup-gui-frame)          ; 通常起動用
;; 既にフレームがある場合(通常起動・設定リロード時)は即適用する。
(when (display-graphic-p) (my/setup-gui-frame))

;; --- 日本語入力: Mozc (Google日本語入力相当) ---
;; C-\ で 半角英数 ⇔ 日本語 をトグルする。
(add-to-list 'load-path "/usr/share/emacs/site-lisp/emacs-mozc")
(when (require 'mozc nil t)
  (setq default-input-method "japanese-mozc")
  ;; 変換候補をエコーエリアに表示 (GUI/端末どちらでも安定)
  (setq mozc-candidate-style 'echo-area))

(require 'server)
(unless (server-running-p) (server-start))

;; ==========================================
;; tmux/ターミナル環境での自動クリップボード同期を強制遮断
;; ==========================================
;; NOTE: `daemonp' を条件に加える。デーモン起動時は (display-graphic-p) が nil のため、
;; この遮断が誤って走り interprogram-paste-function を nil に潰していた(=eg フレームで
;; クリップボード貼り付け不可の原因)。純粋な端末専用 emacs(-nw かつ非デーモン)でのみ遮断する。
;; NOTE: interprogram-cut-function は nil にしない。clipetty が :around で委譲先に
;; するため、nil にすると (funcall nil) で落ちる。端末での送信は clipetty が担う。
(unless (or (display-graphic-p) (daemonp))
  (setq interprogram-paste-function nil))

;; --- 端末(-nw)用クリップボード自動同期: clipetty ---
;; 端末フレームでキル(M-w / C-w / C-k …)するたびに OSC 52 で Windows クリップボードへ
;; 自動送信する。tmux / ssh の入れ子も clipetty が自動処理する。
;; global-clipetty-mode はフレーム種別を見て動くため、GUI(WSLg)フレームでは何もしない。
;; → デーモン1本で GUI と端末を両方開く構成でも安全に共存する。
;; コピーは clipetty(端末) と native 連携(GUI) が自動で担うため、明示コピー用の
;; 手書き関数・C-c c バインドは廃止した。
(leaf clipetty
  :straight t
  :config
  (global-clipetty-mode 1))

(message "init_WSL2.el has been loaded successfully.")


;; フォント設定は上の `my/setup-gui-frame'(after-make-frame-functions)に統合済み。
;; 旧 `font-setup'(window-setup-hook 版)はデーモンで発火せず効かなかったため削除。
