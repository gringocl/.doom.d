;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Miles Starkenburg"
      user-mail-address "milesstarkenburg@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Source Code Pro" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-vibrant)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq roam-dir "~/org/roam")
(setq org-directory "~/org/"
      org-roam-directory roam-dir
      org-journal-dir roam-dir
      deft-directory roam-dir)

(setq org-journal-date-prefix "#+title: "
      org-journal-file-format "%Y-%m-%d.org"
      org-journal-date-format "%A, %d %B %Y"
      org-journal-enable-agenda-integration t)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; personal config
(setq evil-escape-key-sequence "jk"
      projectile-project-search-path '("~/Projects" "~/.doom.d" "~/.spacemacs.d")
      doom-localleader-key ",")

;; Start in fullscreen mode
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
;;
;;; <leader>
(map! :leader :nv ":" nil)
(map! :leader
      :desc "M-x" "SPC" #'execute-extended-command
      :desc "Search project root with ripgrep" "/" #'+ivy/project-search
      :desc "Switch to previous buffer" "TAB" #'evil-switch-to-windows-last-buffer
      :desc "Evil comment" ";" #'evilnc-comment-operator
      :desc "Popup eshell project root" ";" #'evilnc-comment-operator
      (:prefix-map ("`" . "workspace")))

;; Hybrid mode in insert mode
(use-package evil
  :custom
  evil-disable-insert-state-bindings t
  )

;; tmux style movements
(map! "C-h" 'windmove-left
      "C-j" 'windmove-down
      "C-k" 'windmove-up
      "C-l" 'windmove-right)

;; vim-vinegar style
(map! :n "-" 'dired-jump)

(map! "C-<return>" 'ivy-immediate-done)

(add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2)))

(map! :localleader
      :map tide-mode-map
      "p"   #'tide-format
      "f"   #'tide-fix
      "rrx" #'tide-refactor
      "rrf" #'tide-rename-file
      "rrs" #'tide-rename-symbol
      "roi" #'tide-organize-imports)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; (setq web-mode-engines-alist '(("elixir" . "\\.[le]?ex\\'")))

;; ;;; elixir-web-modes
;; (sp-with-modes 'elixir-mode
;;   (sp-local-pair "<%" "%>")
;;   (sp-local-pair "<" ">"))

;; (use-package emmet-mode
;;   :hook (poly-elixir-web-mode))

(after! web-mode
  (defun my-web-mode-hook ()
    (setq web-mode-markup-indent-offset 2
          web-mode-css-indent-offset 2
          web-mode-scss-indent-offset 2
          web-mode-code-indent-offset 2))

  (add-hook 'web-mode-hook  'my-web-mode-hook))

(use-package lsp-mode
  :hook (elixir-mode . lsp)
  :commands (lsp lsp-deferred)
  ;; :ensure t
  :diminish lsp-mode
  :config
  (add-to-list 'exec-path "~/Projects/elixir-ls/release")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]_build")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]deps")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]priv")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]pgdata")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\].elixir_ls")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\].elixir_ls")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]assets/node_modules")
  :init
  )

(defvar org-projectile-file "TODOs.org")
(use-package org-projectile
  :commands (org-projectile-location-for-project)
  :init
  (progn
    (with-eval-after-load 'org-capture
      (require 'org-projectile)))
  :config
  (if (file-name-absolute-p org-projectile-file)
      (progn
        (setq org-projectile-projects-file org-projectile-file)
        (push (org-projectile-project-todo-entry :empty-lines 1)
              org-capture-templates))
    (org-projectile-per-project)
    (setq org-projectile-per-project-filepath org-projectile-file))
  (map! :leader
        (:prefix "p"
         :desc "Open project TODO" "o" #'org-projectile/goto-todos
         :desc "Capture project TODO" "c" #'org-projectile/capture)
        ))

(defun org-projectile/capture (&optional arg)
  (interactive "P")
  (if arg
      (org-projectile-project-todo-completing-read :empty-lines 1)
    (org-projectile-capture-for-current-project :empty-lines 1)))

(defun org-projectile/goto-todos ()
  (interactive)
  (org-projectile-goto-location-for-project (projectile-project-name)))

(use-package ox-reveal
  :config
  (setq org-reveal-root "Users/miles/Projects/reveal.js")
  )

(use-package! lsp-tailwindcss :init (setq! lsp-tailwindcss-add-on-mode t))

(setq flycheck-stylelintrc "assets/.stylelintrc.json")
(after! (:any css-mode scss-mode)
  (add-hook 'css-mode-local-vars-hook
            (lambda ()
              (flycheck-select-checker 'css-stylelint)))
  (add-hook 'scss-mode-local-vars-hook
            (lambda ()
              (flycheck-select-checker 'scss-stylelint)))
  )

;; wrap lines in output buffers
(defun my-compilation-mode-hook ()
  (setq truncate-lines nil) ;; automatically becomes buffer local
  (set (make-local-variable 'truncate-partial-width-windows) nil))
(add-hook 'compilation-mode-hook 'my-compilation-mode-hook)

;; (setq-hook! 'elixir-mode-hook +format-with-lsp nil)
