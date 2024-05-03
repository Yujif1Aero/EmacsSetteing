;; ((nil . ((lsp-file-watch-ignored . (".git/"
;;                                     "build/"
;;                                     "apps/m**"
;;                                     "apps/a**"
;;                                     "examples"
;;                                     "config"
;;                                     "doc"
;;                                     "hooks"
;;                                     "tests"
;;                                     "dist"
;;                                     "node_modules/"
;;                                     "*.lock.json"))))
;;  (c++-mode . ((eval . (lsp)))))


;; ((nil . ((eval . (when (derived-mode-p 'c++-mode)
;;                     (require 'lsp-mode)
;;                     (lsp-deferred)
;;                     (setq lsp-file-watch-ignored
;;                           '(
;;                             "[/\\\\]\\.git$"
;;                             "[/\\\\]build$"
;;                             ;; "[/\\\\]apps/m.*"
;;                             ;; "[/\\\\]apps/a.*"
;;                             ;; "[/\\\\]apps/b.*"
;;                             ;; "[/\\\\]apps/c.*"
;;                             ;; "[/\\\\]apps/d.*"
;;                             ;; "[/\\\\]apps/e.*"
;;                             ;; "[/\\\\]apps/f.*"
;;                             ;; "[/\\\\]apps/g.*"
;;                             ;; "[/\\\\]apps/h.*"
;;                             ;; "[/\\\\]apps/i.*"
;;                             ;; "[/\\\\]apps/j.*"
;;                             ;; "[/\\\\]apps/k.*"
;;                             ;; "[/\\\\]apps/l.*"
;;                             ;; "[/\\\\]apps/n.*"
;;                             ;; "[/\\\\]apps/o.*"
;;                             ;; "[/\\\\]apps/p.*"
;;                             ;; "[/\\\\]apps/q.*"
;;                             ;; "[/\\\\]apps/r.*"
;;                             ;; "[/\\\\]apps/s.*"
;;                             ;; "[/\\\\]apps/t.*"
;;                             ;; "[/\\\\]apps/u.*"
;;                             ;; "[/\\\\]apps/v.*"
;;                             "[/\\\\]apps/[a-x,z].*"
;;                             "[/\\\\]examples$"
;;                             "[/\\\\]config$"
;;                             "[/\\\\]dist$"
;;                             "[/\\\\]doc$"
;;                             "[/\\\\]hooks$"
;;                             "[/\\\\]tests$"
;;                             "[/\\\\]dist$"
;;                             "[/\\\\]node_modules$"
;;                             "[/\\\\]\\..*"
;;                             "\\`\\*.*\\.lock\\.json\\'"
;;                             )))))))

;; ((nil . ((eval . (progn
;;                     (add-hook 'lsp-mode-hook
;;                               (lambda ()
;;                                 (when (derived-mode-p 'c++-mode)
;;                                   (setq lsp-file-watch-ignored
;;                                         '(
;;                                           "[/\\\\]\\.git$"
;;                                           "[/\\\\]build$"
;;                                           "[/\\\\]apps/[a-x,z]*"
;;                                           "[/\\\\]examples$"
;;                                           "[/\\\\]config$"
;;                                           "[/\\\\]dist$"
;;                                           "[/\\\\]doc$"
;;                                           "[/\\\\]hooks$"
;;                                           "[/\\\\]tests$"
;;                                           "[/\\\\]dist$"
;;                                           "[/\\\\]node_modules$"
;;                                           "[/\\\\]\\..*"
;;                                           "\\`\\*.*\\.lock\\.json\\'")))))))
;;           (c++-mode . ((eval . (require 'lsp-mode) (lsp-deferred))))))




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


((nil . ((eval . (add-hook 'lsp-mode-hook
                           (lambda ()
                             (when (derived-mode-p 'c++-mode)
                               (setq lsp-file-watch-ignored
                                     '("[/\\\\]\\.git$"
                                       "[/\\\\]build$"
                                       "[/\\\\]apps/[a-z]*"
                                       "[/\\\\]examples$"
                                       "[/\\\\]config$"
                                       "[/\\\\]doc$"
                                       "[/\\\\]hooks$"
                                       "[/\\\\]tests$"
                                       "[/\\\\]dist$"
                                       "[/\\\\]node_modules$"
                                       "[/\\\\]\\..*"
                                       "\\`\\*.*\\.lock\\.json\\'")))))))))
