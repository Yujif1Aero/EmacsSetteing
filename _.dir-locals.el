;;c++のファイルを開いたとき lspを起動して，特定のフォルダを無視するように設定
;; ((nil . ((eval . (add-hook 'lsp-mode-hook
;;                            (lambda ()
;;                              (when (derived-mode-p 'c++-mode)
;;                                (setq lsp-file-watch-ignored
;;                                      '(
;;                                        "[/\\\\]\\.git$"
;;                                        "[/\\\\]build$"
;;                                        "[/\\\\]apps/[a-x,z]*"
;;                                        "[/\\\\]examples$"
;;                                        "[/\\\\]config$"
;;                                        "[/\\\\]doc$"
;;                                        "[/\\\\]hooks$"
;;                                        "[/\\\\]tests$"
;;                                        "[/\\\\]dist$"
;;                                        "[/\\\\]node_modules$"
;;                                        "[/\\\\]\\..*"
;;                                        "\\`\\*.*\\.lock\\.json\\'"
;;                                        ))))))
;;           (c++-mode . ((eval . (require 'lsp-mode) (lsp-deferred))))))

;;lsp-modeが有効な時にのみ、特定のフォルダを無視するように設定
((nil . ((eval . (add-hook 'lsp-mode-hook
                           (lambda ()
                             (when (derived-mode-p 'c++-mode)
                               (setq lsp-file-watch-ignored
                                     '("[/\\\\]\\.git$"
                                       "[/\\\\]build$"
                                       "[/\\\\]apps/[a-x,z]*"
                                       "[/\\\\]examples$"
                                       "[/\\\\]config$"
                                       "[/\\\\]doc$"
                                       "[/\\\\]hooks$"
                                       "[/\\\\]tests$"
                                       "[/\\\\]dist$"
                                       "[/\\\\]node_modules$"
                                       "[/\\\\]\\..*"
                                       "\\`\\*.*\\.lock\\.json\\'")))))))))
