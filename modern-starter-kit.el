;;; modern-starter-kit.el --- My updates to esk
;;
;; Author: Brandon van Beekum
;; URL: http://www.emacswiki.org/cgi-bin/wiki/StarterKit
;; Version: 2.0.2
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;;###autoload
(progn

  (defun msk-local-column-number-mode ()
    (make-local-variable 'column-number-mode)
    (column-number-mode t))

  (defun msk-local-comment-auto-fill ()
    (set (make-local-variable 'comment-auto-fill-only-comments) t)
    (auto-fill-mode t))

  (defun msk-turn-on-hl-line-mode ()
    (when (> (display-color-cells) 8)
      (hl-line-mode t)))

  (defun msk-turn-on-save-place-mode ()
    (require 'saveplace)
    (setq save-place t))

  (defun msk-pretty-lambdas ()
    (font-lock-add-keywords
     nil `(("(?\\(lambda\\>\\)"
            (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                      ,(make-char 'greek-iso8859-7 107))
                      nil))))))

  (defun msk-add-watchwords ()
    (font-lock-add-keywords
     nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|HACK\\|REFACTOR\\|NOCOMMIT\\)"
            1 font-lock-warning-face t))))

  (add-hook 'prog-mode-hook 'msk-local-column-number-mode)
  (add-hook 'prog-mode-hook 'msk-local-comment-auto-fill)
  (add-hook 'prog-mode-hook 'msk-turn-on-hl-line-mode)
  (add-hook 'prog-mode-hook 'msk-turn-on-save-place-mode)
  (add-hook 'prog-mode-hook 'msk-pretty-lambdas)
  (add-hook 'prog-mode-hook 'msk-add-watchwords)
  ;; (add-hook 'prog-mode-hook 'idle-highlight-mode)

  (defun msk-prog-mode-hook ()
    (run-hooks 'prog-mode-hook))

  (defun msk-turn-off-tool-bar ()
    (if (functionp 'tool-bar-mode) (tool-bar-mode -1)))

  (defun msk-untabify-buffer ()
    (interactive)
    (untabify (point-min) (point-max)))

  (defun msk-indent-buffer ()
    (interactive)
    (indent-region (point-min) (point-max)))

  (defun msk-cleanup-buffer ()
    "Perform a bunch of operations on the whitespace content of a buffer."
    (interactive)
    (msk-indent-buffer)
    (msk-untabify-buffer)
    (delete-trailing-whitespace))

  (when window-system
    (setq frame-title-format '(buffer-file-name "%f" ("%b")))
    (tooltip-mode -1)
    (mouse-wheel-mode t)
    (blink-cursor-mode -1))

  ;; can't do it at launch or emacsclient won't always honor it
  (add-hook 'before-make-frame-hook 'msk-turn-off-tool-bar)

  (setq visible-bell t
        inhibit-startup-message t
        color-theme-is-global t
        sentence-end-double-space nil
        shift-select-mode nil
        mouse-yank-at-point t
        uniquify-buffer-name-style 'forward
        whitespace-style '(face trailing lines-tail tabs)
        whitespace-line-column 80
        ediff-window-setup-function 'ediff-setup-windows-plain
        oddmuse-directory (concat user-emacs-directory "oddmuse")
        save-place-file (concat user-emacs-directory "places")
        backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
        diff-switches "-u")

  (add-to-list 'safe-local-variable-values '(lexical-binding . t))
  (add-to-list 'safe-local-variable-values '(whitespace-line-column . 80))

  ;; Set this to whatever browser you use
  ;; (setq browse-url-browser-function 'browse-url-firefox)
  ;; (setq browse-url-browser-function 'browse-default-macosx-browser)
  ;; (setq browse-url-browser-function 'browse-default-windows-browser)
  ;; (setq browse-url-browser-function 'browse-default-kde)
  ;; (setq browse-url-browser-function 'browse-default-epiphany)
  ;; (setq browse-url-browser-function 'browse-default-w3m)
  ;; (setq browse-url-browser-function 'browse-url-generic
  ;;       browse-url-generic-program "~/src/conkeror/conkeror")

  ;; Highlight matching parentheses when the point is on them.
  (show-paren-mode 1)

  ;; ido-mode is like magic pixie dust!
  (ido-mode t)
  ;; (ido-ubiquitous-mode)
  (setq ido-enable-prefix nil
        ido-enable-flex-matching t
        ido-auto-merge-work-directories-length nil
        ido-create-new-buffer 'always
        ido-use-filename-at-point 'guess
        ido-use-virtual-buffers t
        ido-handle-duplicate-virtual-buffers 2
        ido-max-prospects 10)

  (require 'ffap)
  (defvar ffap-c-commment-regexp "^/\\*+"
    "Matches an opening C-style comment, like \"/***\".")

  (defadvice ffap-file-at-point (after avoid-c-comments activate)
    "Don't return paths like \"/******\" unless they actually exist.

This fixes the bug where ido would try to suggest a C-style
comment as a filename."
    (ignore-errors
      (when (and ad-return-value
                 (string-match-p ffap-c-commment-regexp
                                 ad-return-value)
                 (not (ffap-file-exists-string ad-return-value)))
        (setq ad-return-value nil))))

  (set-default 'indent-tabs-mode nil)
  (set-default 'indicate-empty-lines t)
  (set-default 'imenu-auto-rescan t)

  (add-hook 'text-mode-hook 'turn-on-auto-fill)
  ;; (when (executable-find ispell-program-name)
  ;;       (add-hook 'text-mode-hook 'turn-on-flyspell))

  (eval-after-load "ispell"
    '(when (executable-find ispell-program-name)
       (add-hook 'text-mode-hook 'turn-on-flyspell)))

  (defalias 'yes-or-no-p 'y-or-n-p)
  (defalias 'auto-tail-revert-mode 'tail-mode)

  (random t) ;; Seed the random-number generator

  ;; Hippie expand: at times perhaps too hip
  (eval-after-load 'hippie-exp
    '(progn
       (dolist (f '(try-expand-line try-expand-list try-complete-file-name-partially))
         (delete f hippie-expand-try-functions-list))

       ;; Add this back in at the end of the list.
       (add-to-list 'hippie-expand-try-functions-list 'try-complete-file-name-partially t)))

  (eval-after-load 'grep
    '(when (boundp 'grep-find-ignored-files)
       (add-to-list 'grep-find-ignored-files "*.class")))

  ;; Cosmetics

  (eval-after-load 'diff-mode
    '(progn
       (set-face-foreground 'diff-added "green4")
       (set-face-foreground 'diff-removed "red3")))

  ;; Get around the emacswiki spam protection
  (eval-after-load 'oddmuse
    (add-hook 'oddmuse-mode-hook
              (lambda ()
                (unless (string-match "question" oddmuse-post)
                  (setq oddmuse-post (concat "uihnscuskc=1;" oddmuse-post))))))

  ;; Turn off mouse interface early in startup to avoid momentary display
  (dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
    (when (fboundp mode) (funcall mode -1)))

  ;; You can keep system- or user-specific customizations here
  (setq msk-system-config (concat user-emacs-directory system-name ".el")
        msk-user-config (concat user-emacs-directory user-login-name ".el")
        msk-user-dir (concat user-emacs-directory user-login-name))

  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  ;; (smex-initialize)
  (global-set-key (kbd "M-x") 'smex)

  (defun msk-eval-after-init (form)
    "Add `(lambda () FORM)' to `after-init-hook'.

    If Emacs has already finished initialization, also eval FORM immediately."
    (let ((func (list 'lambda nil form)))
      (add-hook 'after-init-hook func)
      (when after-init-time
        (eval form))))

  (msk-eval-after-init
   '(progn
      (when (file-exists-p msk-system-config) (load msk-system-config))
      (when (file-exists-p msk-user-config) (load msk-user-config))
      (when (file-exists-p msk-user-dir)
        (mapc 'load (directory-files msk-user-dir t "^[^#].*el$")))))

  ;; It's all about the project.
  (global-set-key (kbd "C-c f") 'find-file-in-project)

  ;; You know, like Readline.
  (global-set-key (kbd "C-M-h") 'backward-kill-word)

  ;; Completion that uses many different methods to find options.
  (global-set-key (kbd "M-/") 'hippie-expand)

  ;; Perform general cleanup.
  (global-set-key (kbd "C-c n") 'msk-cleanup-buffer)

  ;; Turn on the menu bar for exploring new modes
  (global-set-key (kbd "C-<f10>") 'menu-bar-mode)

  ;; Font size
  (define-key global-map (kbd "C-+") 'text-scale-increase)
  (define-key global-map (kbd "C--") 'text-scale-decrease)

  ;; Use regex searches by default.
  (global-set-key (kbd "C-s") 'isearch-forward-regexp)
  (global-set-key (kbd "\C-r") 'isearch-backward-regexp)
  (global-set-key (kbd "M-%") 'query-replace-regexp)
  (global-set-key (kbd "C-M-s") 'isearch-forward)
  (global-set-key (kbd "C-M-r") 'isearch-backward)
  (global-set-key (kbd "C-M-%") 'query-replace)

  ;; Jump to a definition in the current file. (Protip: this is awesome.)
  (global-set-key (kbd "C-x C-i") 'imenu)

  ;; File finding
  (global-set-key (kbd "C-x M-f") 'ido-find-file-other-window)
  (global-set-key (kbd "C-c y") 'bury-buffer)
  (global-set-key (kbd "C-c r") 'revert-buffer)

  ;; Window switching. (C-x o goes to the next window)
  (windmove-default-keybindings) ;; Shift+direction
  (global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1))) ;; back one
  (global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2))) ;; forward two

  ;; Start eshell or switch to it if it's active.
  (global-set-key (kbd "C-x m") 'eshell)

  ;; Start a new eshell even if one is active.
  (global-set-key (kbd "C-x M") (lambda () (interactive) (eshell t)))

  ;; Start a regular shell if you prefer that.
  (global-set-key (kbd "C-x C-m") 'shell)

  ;; If you want to be able to M-x without meta (phones, etc)
  (global-set-key (kbd "C-c x") 'execute-extended-command)

  ;; Help should search more than just commands
  (define-key 'help-command "a" 'apropos)

  ;; Should be able to eval-and-replace anywhere.
  (global-set-key (kbd "C-c e") 'msk-eval-and-replace)

  ;; M-S-6 is awkward
  (global-set-key (kbd "C-c q") 'join-line)

  ;; So good!
  (global-set-key (kbd "C-c g") 'magit-status)

  ;; This is a little hacky since VC doesn't support git add internally
  (eval-after-load 'vc
    (define-key vc-prefix-map "i"
      '(lambda () (interactive)
         (if (not (eq 'Git (vc-backend buffer-file-name)))
             (vc-register)
           (shell-command (format "git add %s" buffer-file-name))
           (message "Staged changes.")))))

  ;; Activate occur easily inside isearch
  (define-key isearch-mode-map (kbd "C-o")
    (lambda () (interactive)
      (let ((case-fold-search isearch-case-fold-search))
        (occur (if isearch-regexp isearch-string (regexp-quote isearch-string))))))

  (add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
  (add-hook 'emacs-lisp-mode-hook 'msk-remove-elc-on-save)
  (add-hook 'emacs-lisp-mode-hook 'msk-prog-mode-hook)

  (defun msk-remove-elc-on-save ()
    "If you're saving an elisp file, likely the .elc is no longer valid."
    (make-local-variable 'after-save-hook)
    (add-hook 'after-save-hook
              (lambda ()
                (if (file-exists-p (concat buffer-file-name "c"))
                    (delete-file (concat buffer-file-name "c"))))))

  (define-key emacs-lisp-mode-map (kbd "C-c v") 'eval-buffer)
  (define-key read-expression-map (kbd "TAB") 'lisp-complete-symbol)
  (define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)

  ;; TODO: look into parenface package
  (defface msk-paren-face
    '((((class color) (background dark))
       (:foreground "grey50"))
      (((class color) (background light))
       (:foreground "grey55")))
    "Face used to dim parentheses."
    :group 'starter-kit-faces)

  (dolist (mode '(scheme emacs-lisp lisp clojure clojurescript racket))
    (when (> (display-color-cells) 8)
      (font-lock-add-keywords (intern (concat (symbol-name mode) "-mode"))
                              '(("(\\|)" . 'msk-paren-face))))
    (add-hook (intern (concat (symbol-name mode) "-mode-hook"))
              'paredit-mode))

  (defun msk-pretty-fn ()
    (font-lock-add-keywords nil `(("(\\(\\<fn\\>\\)"
                                   (0 (progn (compose-region (match-beginning 1)
                                                             (match-end 1)
                                                             "\u0192"
                                                             'decompose-region)))))))
  (add-hook 'clojure-mode-hook 'msk-pretty-fn)
  (add-hook 'clojurescript-mode-hook 'msk-pretty-fn)
  )

(provide 'modern-starter-kit.el)
;;; modern-starter-kit.el ends here
