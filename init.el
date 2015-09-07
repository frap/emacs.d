;; =============================================================
;; prelude

;; C-u 0 M-x byte-recompile-directory

(setq inhibit-startup-screen t)

(if window-system
    (progn
      (scroll-bar-mode -1)
      (tool-bar-mode -1)
      (set-face-attribute 'default nil :height 140))
  (menu-bar-mode 0))

;; =============================================================
;; package

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://stable.melpa.org/packages/") t)

(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/") t)

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defun maybe-install-and-require (p)
  (when (not (package-installed-p p))
    (package-install p))
  (require p))

(maybe-install-and-require 'diminish)

;; =============================================================
;; Major modes

;; Clojure
(maybe-install-and-require 'clojure-mode)
(setq auto-mode-alist (cons '("\\.cljs$" . clojure-mode) auto-mode-alist))

(maybe-install-and-require 'inf-clojure)
(diminish 'inf-clojure-minor-mode " λ")
(add-hook 'inf-clojure-minor-mode-hook
          (lambda () (setq completion-at-point-functions nil)))
(add-hook 'clojure-mode-hook 'inf-clojure-minor-mode)

(defun reload-current-clj-ns (next-p)
  (interactive "P")
  (let ((ns (clojure-find-ns)))
    (message (format "Loading %s ..." ns))
    (inf-clojure-eval-string (format "(require '%s :reload)" ns))
    (when (not next-p) (inf-clojure-eval-string (format "(in-ns '%s)" ns)))))

(defun find-tag-without-ns (next-p)
  (interactive "P")
  (find-tag (first (last (split-string (symbol-name (symbol-at-point)) "/")))
            next-p))

(defun erase-inf-buffer ()
  (interactive)
  (with-current-buffer (get-buffer "*inf-clojure*")
    (inf-clojure-clear-repl-buffer)))

(add-hook 'clojure-mode-hook
          '(lambda ()
             (define-key clojure-mode-map "\C-c\C-k" 'reload-current-clj-ns)
             (define-key clojure-mode-map "\M-." 'find-tag-without-ns)
             (define-key clojure-mode-map "\C-cl" 'erase-inf-buffer)
             (define-key clojure-mode-map "\C-c\C-t" 'clojure-toggle-keyword-string)
	     (setq mode-name " λ") ))
(add-hook 'inf-clojure-mode-hook
          '(lambda ()
             (define-key inf-clojure-mode-map "\C-cl" 'erase-inf-buffer)))

;; Markdown
(maybe-install-and-require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; Puppet
;(maybe-install-and-require 'puppet-mode)

;; Yaml
(maybe-install-and-require 'yaml-mode)

;; Docker
(maybe-install-and-require 'dockerfile-mode)

;; Mustache
(maybe-install-and-require 'mustache-mode)

;; Dired
(require 'dired)
(setq dired-dwim-target t)
(defun kill-dired-buffers ()
  (interactive)
  (mapc (lambda (buffer)
          (when (eq 'dired-mode (buffer-local-value 'major-mode buffer))
            (kill-buffer buffer)))
        (buffer-list)))
(add-hook 'dired-mode-hook
          '(lambda ()
             (define-key dired-mode-map "\C-x\M-q" 'wdired-change-to-wdired-mode)
             (define-key dired-mode-map "\C-x\M-f" 'find-name-dired)))

;; =============================================================
;; Minor modes

;; Cider
(maybe-install-and-require 'cider)
(diminish 'cider-mode " Cdr")
(setq cider-repl-history-file "~/.emacs.d/cider-history")
(setq cider-repl-use-pretty-printing nil)
(setq cider-repl-use-clojure-font-lock t)
(setq cider-repl-result-prefix ";; => ")
(setq cider-repl-wrap-history t)
(setq cider-repl-history-size 3000)
(add-hook 'cider-mode-hook #'eldoc-mode)
(setq cider-show-error-buffer 'except-in-repl)

;; clj-refactor
(maybe-install-and-require 'clj-refactor)
(diminish 'clj-refactor-mode)
(add-hook 'clojure-mode-hook (lambda ()
                               (clj-refactor-mode 1)
                               (cljr-add-keybindings-with-prefix "C-c C-o")))

;; align-cljlet
(maybe-install-and-require 'align-cljlet)
(add-hook 'clojure-mode-hook
          '(lambda ()
             (define-key clojure-mode-map "\C-c\C-y" 'align-cljlet)))

;; paredit
(maybe-install-and-require 'paredit)
(diminish 'paredit-mode " {}")
(add-hook 'lisp-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)
(add-hook 'scheme-mode-hook 'paredit-mode)
(add-hook 'cider-repl-mode-hook 'paredit-mode)
(add-hook 'clojure-mode-hook 'paredit-mode)

;; smartparens
(maybe-install-and-require 'smartparens)
(sp-use-paredit-bindings)
(sp-pair "'" nil :actions :rem)
(add-hook 'ruby-mode-hook 'smartparens-mode)
(add-hook 'inf-clojure-mode-hook 'smartparens-mode)

;; flycheck
(maybe-install-and-require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

;; projectile
(maybe-install-and-require 'projectile)
(setq projectile-mode-line '(:eval (format " P[%s]" (projectile-project-name))))
(add-hook 'clojure-mode-hook 'projectile-mode)
(add-hook 'ruby-mode-hook 'projectile-mode)

;; inf-ruby
(maybe-install-and-require 'inf-ruby)
(add-hook 'ruby-mode-hook 'inf-ruby-minor-mode)

;; Magit
(maybe-install-and-require 'magit)
(setq magit-last-seen-setup-instructions "1.4.0")
(setq magit-revert-buffers 'silent)
(setq magit-diff-refine-hunk t)

;; git gutter
(maybe-install-and-require 'git-gutter)
(diminish 'git-gutter-mode "gg")

;; silver searcher
(maybe-install-and-require 'ag)
(setq ag-highlight-search t)
(setq ag-reuse-buffers t)
(defun ag-search (string file-regex directory)
  (interactive (list (read-from-minibuffer "Search string: " (ag/dwim-at-point))
                     (read-from-minibuffer "In filenames matching PCRE: " (ag/buffer-extension-regex))
                     (read-directory-name "Directory: " (ag/project-root default-directory))))
  (ag/search string directory :file-regex file-regex))

;; eldoc
(diminish 'eldoc-mode "doc")
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)

;; hl-sexp
(maybe-install-and-require 'hl-sexp)
(add-hook 'clojure-mode-hook 'hl-sexp-mode)
(add-hook 'lisp-mode-hook 'hl-sexp-mode)
(add-hook 'scheme-mode-hook 'hl-sexp-mode)
(add-hook 'emacs-lisp-mode-hook 'hl-sexp-mode)

;; idle-highlight-mode
(maybe-install-and-require 'idle-highlight-mode)
(add-hook 'clojure-mode-hook 'idle-highlight-mode)
(add-hook 'lisp-mode-hook 'idle-highlight-mode)
(add-hook 'scheme-mode-hook 'idle-highlight-mode)
(add-hook 'emacs-lisp-mode-hook 'idle-highlight-mode)
(add-hook 'haskell-mode-hook 'idle-highlight-mode)

;; Golden Ratio
(maybe-install-and-require 'golden-ratio)
(diminish 'golden-ratio-mode "Au")
(golden-ratio-mode 1)
(add-to-list 'golden-ratio-exclude-modes "ediff-mode")

;; undo-tree
(maybe-install-and-require 'undo-tree)
(diminish 'undo-tree-mode " τ")
(global-undo-tree-mode)

;; yasnippet
(maybe-install-and-require 'yasnippet)
(diminish 'yas-minor-mode " γ")
(maybe-install-and-require 'clojure-snippets)
(yas-global-mode 1)
(add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
(yas-load-directory "~/.emacs.d/snippets")

;; company mode
(maybe-install-and-require 'company)
(diminish 'company-mode)

(require 'company-etags)
(add-to-list 'company-etags-modes 'clojure-mode)
(add-hook 'after-init-hook 'global-company-mode)

;; browse-kill-ring
(maybe-install-and-require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; multiple cursors
(maybe-install-and-require 'multiple-cursors)

;; IDO
(maybe-install-and-require 'ido-ubiquitous)
(ido-mode t)
(ido-ubiquitous)
(setq ido-enable-flex-matching t)
(global-set-key "\M-x"
                (lambda ()
                  (interactive)
                  (call-interactively
                   (intern (ido-completing-read "M-x " (all-completions "" obarray 'commandp))))))

;; expand region
(maybe-install-and-require 'expand-region)

;; yagist
(maybe-install-and-require 'yagist)
(maybe-install-and-require 'kaesar)
(setq yagist-encrypt-risky-config t)

;; flyspell
(require 'flyspell)
(diminish 'flyspell-mode "fly ")

;; linum
(if window-system
  (setq linum-format "%d")
  (setq linum-format "%d "))
(setq linum-modes '(clojure-mode emacs-lisp-mode tuareg-mode ruby-mode markdown-mode python-mode js-mode html-mode css-mode c-mode-common))
(--each linum-modes (add-hook (intern (s-concat (symbol-name it) "-hook")) 'linum-mode))

;; avy
(maybe-install-and-require 'avy)

;; show time
(setq display-time-24hr-format t)
(setq display-time-load-average t)
(display-time)

;; jvm-mode
(maybe-install-and-require 'jvm-mode)
(setq jvm-mode-line-string " jvm[%d]")
(jvm-mode)

;; recentf mode
(recentf-mode)
(setq recentf-max-menu-items 25)

(show-paren-mode)
(global-auto-revert-mode t)
(column-number-mode t)

;; =============================================================
;; Color theme

(maybe-install-and-require 'flatland-theme)
(when (not window-system)
  (let ((bg-one (assoc "flatland-bg+1" flatland-colors-alist))
        (bg-two (assoc "flatland-bg+2" flatland-colors-alist)))
    (setq flatland-colors-alist (delete bg-one flatland-colors-alist))
    (add-to-list 'flatland-colors-alist (cons "flatland-bg+1" (cdr bg-two))))
  (custom-set-faces
   '(company-preview ((t (:background "brightyellow" :foreground "wheat"))))
   '(company-tooltip ((t (:background "brightyellow" :foreground "black"))))))

(custom-set-faces
 '(diff-refine-added ((t (:inherit diff-added :background "#4e4e4e"))))
 '(idle-highlight ((t (:background "#4e4e4e"))))
 '(linum ((t (:foreground "#555"))))
 '(region ((t (:background "#4c4f52")))))

(load-theme 'flatland t)

;; =============================================================
;; Key bindings

;; ibuffer over list-buffers
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; comments
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)

;; better search
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(global-set-key (kbd "RET") 'newline-and-indent)

;; buffer-move
(maybe-install-and-require 'buffer-move)
(global-set-key (kbd "C-c <C-right>") '(lambda ()
                                         (interactive)
                                         (buf-move-right) (golden-ratio)))
(global-set-key (kbd "C-c <C-left>") '(lambda ()
                                        (interactive)
                                        (buf-move-left) (golden-ratio)))
;; magit bindings
(global-set-key (kbd "C-c C-g") 'magit-status)
(global-set-key (kbd "C-c C-b") 'magit-blame-mode)
;; avy commands
(global-set-key (kbd "M-g f") 'avy-goto-line)
(global-set-key (kbd "M-g w") 'avy-goto-word-1)
;; expand region
(global-set-key (kbd "C-\\") 'er/expand-region)
;; recentf
(global-set-key (kbd "C-x C-r") 'recentf-open-files)
;; multiple cursors
(global-set-key (kbd "C-c .") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c ,") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c M-.") 'mc/mark-all-like-this)

;; (global-git-gutter-mode t)
(global-set-key (kbd "C-x C-g") 'git-gutter:toggle)


;; ag search
(global-set-key (kbd "C-x M-f") 'ag-search)
;; =============================================================
;; clean mode-line
(defvar mode-line-cleaner-alist
  `((auto-complete-mode       . " α")
    (yas-minor-mode           . " γ")
    (org-agenda-mode          . "øα")
    (org-mode                 . "ø")
    (org-agenda-day-view      . "")
    (undo-tree-mode           . " τ")
    (paredit-mode             . " {}")
    (eldoc-mode               . " ξd")
    (abbrev-mode              . "")
    (nrepl-mode               . " ηζ")
    (nrepl-interaction-mode   . " ηζ")
    (cider-mode               . " ηζ")
    (cider-interaction        . " ηζ")
    ;; Major modes
    (clojure-mode             . "λ")
    ;(yas-global-mode          . " γ")
    (hi-lock-mode             . "")
    (python-mode              . "π")
    (emacs-lisp-mode          . "ε")
    (nxhtml-mode              . "nx")
    (markdown-mode            . "md")
    (haskell-mode             . "ha")

    )
  "Alist for `clean-mode-line'.

When you add a new element to the alist, keep in mind that you
must pass the correct minor/major mode symbol and a string you
want to use in the modeline *in lieu of* the original.")

(defun clean-mode-line ()
  (interactive)
  (loop for cleaner in mode-line-cleaner-alist
        do (let* ((mode (car cleaner))
                 (mode-str (cdr cleaner))
                 (old-mode-str (cdr (assq mode minor-mode-alist))))
             (when old-mode-str
                 (setcar old-mode-str mode-str))
               ;; major mode
             (when (eq mode major-mode)
               (setq mode-name mode-str)))))


(add-hook 'after-change-major-mode-hook 'clean-mode-line)

;;; Greek letters - C-u C-\ greek ;; C-\ to revert to default
;;; ς
;;; ε
;;; ρ τ υ θ ι ο π α σ δ φ γ η ξ κ λ ζ χ ψ ω β ν μ

;; =============================================================
;; Org-Mode
(require 'org)
;;
;; Standard key bindings
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(global-set-key (kbd "C-c c") 'org-capture)
;; org files
(add-to-list 'load-path (expand-file-name "~/Dropbox/GTD"))
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)"))

;; setup for org-capture
(setq org-directory "~/Dropbox/GTD")
(setq org-default-notes-file "~/Dropbox/GTD/inbox.org")

;; fast-todo-selection
(setq org-use-fast-todo-selection t)
;; use SHIFT left/right for changing todo states without clocking chnages
(setq org-treat-S-cursor-todo-selection-as-state-change nil)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "EN_COURS(n)" "|" "FINI(d)")
              (sequence "ATTENTE(w@/!)" "SOUTE(h@/!)" "|" "ANNULÉ(c@/!)" "TÉLÉPHONE" "RENDEZ_VOUS")
              (sequence "GOAL(g)" "AIM(a)" "|" "FINI(d)"))))
;; todo state change changes
(setq org-todo-state-tags-triggers
      (quote (("ANNULÉ" ("ANNULÉ" . t))
              ("ATTENTE" ("ATTENTE" . t))
              ("SOUTE" ("ATTENTE") ("SOUTE" . t))
              (done ("ATTENTE") ("SOUTE"))
              ("TODO" ("ATTENTE") ("ANNULÉ") ("SOUTE"))
              ("EN_COURS" ("ATTENTE") ("ANNULÉ") ("SOUTE"))
              ("FINI" ("ATTENTE") ("ANNULÉ") ("SOUTE")))))

(setq org-todo-keyword-faces
      '(("UN_JOUR"       :foreground "#c93f80" :weight bold)
        ("EN_COURS"      :foreground "#2f2ccc" :weight bold)
        ("ATTENTE"       :foreground "#fd9b3b" :weight bold)
        ("FINI"          :foreground "#19b85d" :weight bold)
        ("SOUTE"         :foreground "#afff64" :weight bold)
        ("ANNULÉ"        :foreground "#b81590" :weight bold)
        ("TÉLÉPHONE"     :foreground "#2eb9a7" :weight bold)
        ("GOAL"          :foreground "#1010ff" :weight bold)
        ("VALUE"         :foreground "#afff10" :weight bold)
        ("QUOTE"         :foreground "#146290" :weight bold)
        ("DAEMONS"       :foreground "#b46230" :weight bold)
        ("RENDEZ_VOUS"   :foreground "#0f4f43" :weight bold)
        ))
;; sets the TAG list
(setq org-tag-alist '((:startgroup . nil)
                      ("@maision" . ?m)
                      ("@bureau" . ?b)
                      ("@voiture" . ?v)
                      ("@ferme"   . ?f)
                      (:endgroup . nil)
                      ("TÉLÉPHONE" . ?t)
                      ("RENDEZ_VOUS" . ?r)
                      (:startgroup . nil)
                      ("ATTENTE" . ?w)
                      ("SOUTE" . ?h)
                      ("ANNULÉ" . ?a)
                      ("PROXIMO" . ?p)
                      ("UN_JOUR" . ?j)
                      ("EN_COURS" . ?n)
                      (:endgroup . nil)
                      ("en ligne" . ?e)))

(setq org-capture-templates
      '(("t" "todo" entry (file+headline "~/Dropbox/GTD/inbox.org" "Boîte de réception")
         "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
        ("r" "répondre" entry (file+headline "~/Dropbox/GTD/inbox.org" "Répondre")
         "* EN_COURS Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
        ("n" "commentaire" entry (file+headline "~/Dropbox/GTD/inbox.org" "Commentaire")
                        "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
        ("j" "journal" entry (file+datetree "~/Dropbox/GTD/journal.org")
         "* %?\n%U\n" :clock-in t :clock-resume t)
        ("m" "Meeting" entry (file+headline "~/Dropbox/GTD/inbox.org" "Interruptions")
         "* RENDEZ_VOUS avec %? :MEETING:\n%U" :clock-in t :clock-resume t)
        ("p" "appel téléphonique" entry (file+headline "~/Dropbox/GTD/inbox.org" "Interruptions")
         "* TÉLÉPHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
        ("h" "Habitude" entry (file "~/Dropbox/GTD/inbox.org")
                        "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"<%Y-%m-%d %a .+1d/3d>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: EN_COURS\n:END:\n")
        ))

;; DO Not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)
;; Compact the block agenda view
(setq org-agenda-compact-blocks t)
;; Set the default agenda-view to 1 day
(setq org-agenda-span 1)
(setq org-agenda-custom-commands
      '( (" " "Ordre du Jour"
         ((agenda "" nil)
          (alltodo ""
                   ((org-agenda-overriding-header "Tâches à la Représenter")
                    (org-agenda-files '("~/Dropbox/GTD/inbox.org"))
                    ))
          (tags-todo "-ANNULÉ/!-SOUTE-ATTENTE-GOAL"
                     ((org-agenda-overriding-header "Projets Bloqués")
                      ))
          (tags-todo "-ATTENTE-ANNULÉ/!EN_COURS"
                     ((org-agenda-overriding-header "Tâches à Venir")
                      (org-tags-match-list-sublevels t)
                      (org-agenda-sorting-strategy '(priority-down todo-state-down effort-up category-keep))))
          (tags-todo "-ANNULÉ/!-EN_COURS-SOUTE-ATTENTE-VALUE-GOAL"
                     ((org-agenda-overriding-header "Tâches Disponibles")
                      (org-agenda-sorting-strategy '(effort-up priority-down))))
          (tags-todo "-ANNULÉ/!"
                     ((org-agenda-overriding-header "Projets actuellement Actifs")
                      (org-agenda-sorting-strategy '(effort-up priority-down category-keep))))
          (tags-todo "-ANNULÉ/!ATTENTE|SOUTE"
                     ((org-agenda-overriding-header "Attente ou Reporté Tâches")
                      )))
         nil)
        ("r" "Tasks to Refile" alltodo ""
         ((org-agenda-overriding-header "Tasks to Refile")
          (org-agenda-files '("~/.org/inbox.org"))))
        ("#" "Stuck Projects" tags-todo "-ANNULÉ/!-SOUTE-ATTENTE"
         ((org-agenda-overriding-header "Stuck Projects")
          ))
        ("n" "Next Tasks" tags-todo "-ATTENTE-ANNULÉ/!EN_COURS"
         ((org-agenda-overriding-header "Next Tasks")
           (org-tags-match-list-sublevels t)
          (org-agenda-sorting-strategy '(todo-state-down effort-up category-keep))))
        ("R" "Tasks" tags-todo "-ANNULÉ/!-EN_COURS-SOUTE-ATTENTE"
         ((org-agenda-overriding-header "Available Tasks")
                    (org-agenda-sorting-strategy '(category-keep))))
        ("p" "Projects" tags-todo "-ANNULÉ/!"
         ((org-agenda-overriding-header "Currently Active Projects")
          (org-agenda-sorting-strategy '(category-keep))
          (org-tags-match-list-sublevels 'indented)))
        ("w" "Waiting Tasks" tags-todo "-ANNULÉ/!ATTENTE|SOUTE"
         ((org-agenda-overriding-header "Waiting and Postponed Tasks")
                    ))))



;; =============================================================
;; Mode Settings

;; compojure
(define-clojure-indent
	(defroutes 'defun)
	(GET 2)
	(POST 2)
	(PUT 2)
	(DELETE 2)
	(HEAD 2)
	(ANY 2)
	(context 2))

;; Scheme; gambit / chicken / petite
;;(setq scheme-program-name "gsi -:s,d-")
;;(setq scheme-program-name "csi")
;;(setq scheme-program-name "petite")

;; =============================================================
;; Settings

(setq frame-title-format "%b")
(set-default 'truncate-lines t)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq scroll-step 1)
(setq scroll-error-top-bottom t)
(blink-cursor-mode -1)
(setq ring-bell-function 'ignore)

;; remove trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; match parens
(setq blink-matching-paren-distance nil)

;; spaces instead of tabs
(setq-default indent-tabs-mode nil)
(setq default-tab-width 2)
(setq tab-width 2)
(setq python-indent 4)
(setq c-basic-offset 3)
(setq c-indent-level 3)
(setq c++-tab-always-indent nil)
(setq js-indent-level 2)

;; Write backup files to own directory
(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat user-emacs-directory "backups")))))

;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)

;; Save point position between sessions
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name "places" user-emacs-directory))

;; =============================================================
;; Handy functions

;; XML pretty print
(defun pretty-print-xml-region (begin end)
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    (while (search-forward-regexp "\>[ \\t]*\<" nil t)
      (backward-char) (insert "\n"))
    (indent-region begin end))
  (message "Ah, much better!"))

;; =============================================================
;; OSX

;; Allow hash to be entered
(when (eq 'darwin system-type)

  (global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))

  (maybe-install-and-require 'exec-path-from-shell)
  (exec-path-from-shell-initialize)

  (defun copy-from-osx ()
    (shell-command-to-string "pbpaste"))

	(defun paste-to-osx (text &optional push)
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc))))

  (unless (getenv "TMUX")
    (setq interprogram-cut-function 'paste-to-osx)
    (setq interprogram-paste-function 'copy-from-osx)))
