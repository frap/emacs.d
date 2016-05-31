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
(add-to-list 'load-path (expand-file-name "~/Documents/GTD"))
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)"))

;; setup for org-capture
(setq org-directory "~/Documents/gtd")
(setq org-default-notes-file "~/Documents/gtd/inbox.org")

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
        ("n" "commentaire" entry (file+headline "~/Documents/gtd/inbox.org" "Commentaire")
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
