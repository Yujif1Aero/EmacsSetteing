;;; early-init.el --- パッケージ管理の競合防止用

;; package.el の自動有効化を無効化（straight.el を使うために必須）
(setq package-enable-at-startup nil)

;; 起動時に一度 GUI 要素（メニューバー等）を消すことで、描画のちらつきを抑える
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
