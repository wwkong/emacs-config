;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "William Kong"
      user-mail-address "wwkong92@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
 (setq doom-font (font-spec :family "JetBrains Mono" :size 20 :weight 'semi-light)
     doom-variable-pitch-font (font-spec :family "JetBrains Mono" :size 20))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-spacegrey)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; ----------------------------------------------------------------------------
;; Startup and Profiling
;; ----------------------------------------------------------------------------

(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; Work around a bug where esup tries to step into the byte-compiled
;; version of `cl-lib', and fails horribly.
(setq esup-depth 0)

;; ----------------------------------------------------------------------------
;; org-mode
;; ----------------------------------------------------------------------------

(setq org-ellipsis " ▾")
(setq org-support-shift-select t)

(use-package org-bullets
 :hook (org-mode . org-bullets-mode)
 :custom
 (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")));; Center org writing area.

(defun sl/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . sl/org-mode-visual-fill))

;; ----------------------------------------------------------------------------
;; Aesthetics
;; ----------------------------------------------------------------------------

(add-hook 'org-mode-hook #'doom-disable-line-numbers-h)

(defvar fancy-splash-image-source
  (expand-file-name "splash-image/doomEmacsRouge_mid.svg" doom-private-dir)
  "SVG used for the splash image.")
(setq fancy-splash-image fancy-splash-image-source)

(setq doom-fallback-buffer-name "▸ Doom"
      +doom-dashboard-name "▸ Doom")

;; ----------------------------------------------------------------------------
;; Dashboard
;; ----------------------------------------------------------------------------

(defun +doom-dashboard-setup-modified-keymap ()
  (setq +doom-dashboard-mode-map (make-sparse-keymap))
  (map! :map +doom-dashboard-mode-map
        :desc "Find file" :ne "f" #'find-file
        :desc "Recent files" :ne "r" #'consult-recent-file
        :desc "Config dir" :ne "C" #'doom/open-private-config
        :desc "Open config.org" :ne "c" (cmd! (find-file (expand-file-name "config.org" doom-private-dir)))
        :desc "Open dotfile" :ne "." (cmd! (doom-project-find-file "~/.config/"))
        :desc "Notes (roam)" :ne "n" #'org-roam-node-find
        :desc "Switch buffer" :ne "b" #'+vertico/switch-workspace-buffer
        :desc "Switch buffers (all)" :ne "B" #'consult-buffer
        :desc "IBuffer" :ne "i" #'ibuffer
        :desc "Previous buffer" :ne "p" #'previous-buffer
        :desc "Set theme" :ne "t" #'consult-theme
        :desc "Quit" :ne "Q" #'save-buffers-kill-terminal))

;; Fast access to dashboard.(map! :leader :desc "Dashboard" "d" #'+doom-dashboard/open)
(map! :leader :desc "Dashboard" "d" #'+doom-dashboard/open)

(add-transient-hook! #'+doom-dashboard-mode (+doom-dashboard-setup-modified-keymap))
(add-transient-hook! #'+doom-dashboard-mode :append (+doom-dashboard-setup-modified-keymap))
(add-hook! 'doom-init-ui-hook :append (+doom-dashboard-setup-modified-keymap))

;; Removes all useful commands.
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))

;; Add random phrases.

(defvar splash-phrase-source-folder
  (expand-file-name "splash-text" doom-private-dir)
  "A folder of text files with a fun phrase on each line.")

(defvar splash-phrase-sources
  (let* ((files (directory-files splash-phrase-source-folder nil "\\.txt\\'"))
         (sets (delete-dups (mapcar
                             (lambda (file)
                               (replace-regexp-in-string "\\(?:-[0-9]+-\\w+\\)?\\.txt" "" file))
                             files))))
    (mapcar (lambda (sset)
              (cons sset
                    (delq nil (mapcar
                               (lambda (file)
                                 (when (string-match-p (regexp-quote sset) file)
                                   file))
                               files))))
            sets))
  "A list of cons giving the phrase set name, and a list of files which contain phrase components.")

(defvar splash-phrase-set
  (nth (random (length splash-phrase-sources)) (mapcar #'car splash-phrase-sources))
  "The default phrase set. See `splash-phrase-sources'.")

(defun splase-phrase-set-random-set ()
  "Set a new random splash phrase set."
  (interactive)
  (setq splash-phrase-set
        (nth (random (1- (length splash-phrase-sources)))
             (cl-set-difference (mapcar #'car splash-phrase-sources) (list splash-phrase-set))))
  (+doom-dashboard-reload t))

(defvar splase-phrase--cache nil)

(defun splash-phrase-get-from-file (file)
  "Fetch a random line from FILE."
  (let ((lines (or (cdr (assoc file splase-phrase--cache))
                   (cdar (push (cons file
                                     (with-temp-buffer
                                       (insert-file-contents (expand-file-name file splash-phrase-source-folder))
                                       (split-string (string-trim (buffer-string)) "\n")))
                               splase-phrase--cache)))))
    (nth (random (length lines)) lines)))

(defun splash-phrase (&optional set)
  "Construct a splash phrase from SET. See `splash-phrase-sources'."
  (mapconcat
   #'splash-phrase-get-from-file
   (cdr (assoc (or set splash-phrase-set) splash-phrase-sources))
   " "))

(defun doom-dashboard-phrase ()
  "Get a splash phrase, flow it over multiple lines as needed, and make fontify it."
  (mapconcat
   (lambda (line)
     (+doom-dashboard--center
      +doom-dashboard--width
      (with-temp-buffer
        (insert-text-button
         line
         'action
         (lambda (_) (+doom-dashboard-reload t))
         'face 'doom-dashboard-menu-title
         'mouse-face 'doom-dashboard-menu-title
         'help-echo "Random phrase"
         'follow-link t)
        (buffer-string))))
   (split-string
    (with-temp-buffer
      (insert (splash-phrase))
      (setq fill-column (min 70 (/ (* 2 (window-width)) 3)))
      (fill-region (point-min) (point-max))
      (buffer-string))
    "\n")
   "\n"))

(defadvice! doom-dashboard-widget-loaded-with-phrase ()
  :override #'doom-dashboard-widget-loaded
  (setq line-spacing 0.2)
  (insert
   "\n\n"
   (propertize
    (+doom-dashboard--center
     +doom-dashboard--width
     (doom-display-benchmark-h 'return))
    'face 'doom-dashboard-loaded)
   "\n"
   (doom-dashboard-phrase)
   "\n"))

;; Backup splash
(defun doom-dashboard-draw-ascii-emacs-banner-fn ()
  (let* ((banner
          '(",---.,-.-.,---.,---.,---."
            "|---'| | |,---||    `---."
            "`---'` ' '`---^`---'`---'"))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat
                 line (make-string (max 0 (- longest-line (length line)))
                                   32)))
               "\n"))
     'face 'doom-dashboard-banner)))

(unless (display-graphic-p) ; for some reason this messes up the graphical splash screen atm
  (setq +doom-dashboard-ascii-banner-fn #'doom-dashboard-draw-ascii-emacs-banner-fn))

;; ----------------------------------------------------------------------------
;; dap-mode
;; ----------------------------------------------------------------------------

;; LLDB is a debugger that supports, among others, C, C++, Objective-C and Swift. On Linux, this can be installed using the
;; command =sudo apt-get install lldb=.

;; NOTE: The path to the lldb should be set below in dap-lldb-debug-program!

;; NOTE: C++ progams must be compiled with the -g flag in order to allow debugging.

(use-package dap-mode
  :defer
  :after lsp-mode
  :commands dap-debug
  :custom
  (dap-auto-configure-mode t)
  :config
  (require 'dap-lldb)

  ;; set the debugger executable (c++)
  (setq dap-lldb-debug-program `("/usr/bin/lldb-vscode-10"))

  ;; ask user for executable to debug if not specified explicitly (c++)
  (setq dap-lldb-debugged-program-function (lambda () (read-file-name "Select file to debug.")))

  ;; default debug template for (c++)
  (dap-register-debug-template
   "C++ LLDB dap-mode"
   (list :type "lldb-vscode"
         :cwd nil
         :args nil
         :request "launch"
         :program nil)))

;; ----------------------------------------------------------------------------
;; Programming Config
;; ----------------------------------------------------------------------------

;; Generic hooks. Adds column indicator plus tab widths.
(add-hook 'prog-mode-hook
  (lambda ()
    (visual-line-mode)
    (display-fill-column-indicator-mode)
    (setq display-fill-column-indicator-column 130)
    (setq tab-width 4)
    (set-fill-column 130)
    ))

(after! lsp-ui
  (setq lsp-ui-doc-enable t))
