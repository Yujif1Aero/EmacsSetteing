;;;; init_windows.el --- Settings for Native Windows

;; --- クリップボード ---
(setq select-enable-clipboard t)
;; Windows に PRIMARY セレクションは無い。t のままだと貼り付け時に
;; 余計なクリップボード往復が起きて遅くなるため nil にする。
(setq select-enable-primary nil)

;; --- 文字コード ---
;; GUI Windows のクリップボードは UTF-16LE。ここを合わせないと
;; 日本語の貼り付けが文字化けする（init_common.el の utf-8 設定を上書き）。
(set-selection-coding-system 'utf-16le)
;; 端末/キーボードは GUI では cp932 にする必要がなく、むしろ入力で不利。utf-8 に戻す。
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; ファイル名は Windows 日本語環境の慣例に合わせて cp932 のまま。
(setq file-name-coding-system 'cp932)

;; --- 外部コマンド / PATH ---
;; Windows の Git (git.exe)
(when (executable-find "git.exe")
  (setq magit-git-executable "git.exe"))

;; npm グローバル bin (claude-agent-acp.cmd / codex-acp.cmd の置き場) を
;; exec-path と PATH に追加し、agent-shell から ACP ブリッジを見つけられるようにする。
(let ((npm-bin (expand-file-name "npm" (getenv "APPDATA"))))
  (when (file-directory-p npm-bin)
    (add-to-list 'exec-path npm-bin)
    (setenv "PATH" (concat npm-bin path-separator (getenv "PATH")))))

;; 既定ブラウザは Windows のものを使う
(setq browse-url-browser-function 'browse-url-default-windows-browser)

;; --- 表示 ---
(when (window-system)
  (set-face-attribute 'default nil :family "Meiryo" :height 105))

;; whitespace: Windows では空白1文字ごとの点マーク(space-mark)が重い/字形が崩れる
;; ため無効化する。タブ表示(tab-mark)と末尾空白/タブ強調は残す。
;; ※ init_common.el は変更しないので Linux/WSL は space-mark 表示のまま。
(setq whitespace-display-mappings '((tab-mark ?\t [?> ? ] [?\\ ?\t]))) ; tab を "> " 表示
(with-eval-after-load 'whitespace
  (setq whitespace-style '(face trailing tabs tab-mark))
  (when (bound-and-true-p global-whitespace-mode)
    ;; 既に有効な場合は表示を反映させるためトグルし直す。
    (global-whitespace-mode -1)
    (global-whitespace-mode 1)))

;; --- 日本語入力 ---
;; emacs-mozc は mozc_emacs_helper が必要で Linux 用。Windows では使えないため、
;; tr-ime を使って OS の IME (MS-IME / Google日本語入力 など) を Emacs に統合する。
;; ※ 初回起動時に必要な DLL のダウンロード可否を尋ねられることがある(要ネット接続)。
(leaf tr-ime
  :straight t
  :if (eq window-system 'w32)
  :require t
  :config
  (tr-ime-advanced-install)
  (setq default-input-method "W32-IME")
  (setq-default w32-ime-mode-line-state-indicator "[--]")
  (setq w32-ime-mode-line-state-indicator-list '("[--]" "[あ]" "[--]"))
  (w32-ime-initialize))

;; --- シェル (shell-pop) ---
;; native Windows の Emacs には本物の PTY が無く、対話的 PowerShell は comint/端末
;; いずれとも相性が悪い。そこで shell-pop では PTY 不要で安定動作する eshell を開く。
;; (本物の PowerShell が要るときは Windows Terminal / WSL 側を使う想定)
;; powershell.el は .ps1 編集用のメジャーモードとしてのみ残す。
(leaf powershell
  :straight t
  :commands (powershell run-powershell)
  :mode ("\\.ps1\\'" . powershell-mode))

(leaf shell-pop
  :straight t
  :custom
  (shell-pop-shell-type . '("eshell" "*eshell*" (lambda () (eshell)))))

(message "init_windows.el has been loaded.")
