;;; early-init.el --- パッケージ管理の競合防止用

;; package.el の自動有効化を無効化（straight.el を使うために必須）
(setq package-enable-at-startup nil)

;; --- 起動高速化 ---
;; 起動中は file-name-handler-alist を無効化し、大量の .el 読み込みを高速化する。
;; (起動完了後に元へ戻す。Windows で特に効果が大きい)
(defvar my/saved-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda () (setq file-name-handler-alist my/saved-file-name-handler-alist)))

;; Windows で巨大フォント(Meiryo 等)使用時のフォントキャッシュ GC を抑制する。
(setq inhibit-compacting-font-caches t)
;; プロセス出力の読み取り上限を拡大（シェル/LSP の応答を軽くする）。
(setq read-process-output-max (* 1024 1024))

;; 起動時に一度 GUI 要素（メニューバー等）を消すことで、描画のちらつきを抑える
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
