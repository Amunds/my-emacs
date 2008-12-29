(prefer-coding-system 'utf-8)

(add-to-list 'load-path "~/.emacs.d")

(require 'cl)
(require 'browse-kill-ring)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)
(require 'recentf)
(require 'pastie)
(require 'twittering-mode)
(require 'conservative-mode)
(require 'kill-wspace-mode)

(load "my-settings.el")
(add-to-list 'load-path package-user-dir)

(require 'yasnippet)
(require 'yasnippet-mode)
(yas/initialize)
(yas/load-directory snippet-dir)

;; ELPA
(require 'package)
(package-initialize)

;; Default minor modes
(transient-mark-mode t)
(show-paren-mode t)
(savehist-mode t)
(global-font-lock-mode t)
(ido-mode t)
(recentf-mode t)
(kill-wspace-mode t)
(display-time-mode t)

(if (fboundp 'blink-cursor-mode) (blink-cursor-mode 0))
(menu-bar-mode (if window-system 1 -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))

(fset 'yes-or-no-p 'y-or-n-p)

;; These are damn useful
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(server-start)


;; Load paths
(add-to-list 'load-path "~/.emacs.d/sml-mode")
(add-to-list 'load-path "~/.emacs.d/vendor/ri-emacs")

(require 'ri)
(require 'multi-term)
(multi-term-keystroke-setup)

(require 'textmate)
(textmate-mode)

;; Slime
(when (file-directory-p slime-dir)
  (add-to-list 'load-path slime-dir)
  (require 'slime)

  (eval-after-load "slime"
    '(progn
       (slime-setup '(slime-fancy slime-asdf slime-banner))
       (setq slime-complete-symbol*-fancy t)
       (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)
       )))

;; Regenerate the autoload file if it doesn't exist or it's too
;; old. (2 weeks or so)
(if (or (not (file-exists-p autoload-file))
        (< (+ (car (nth 5 (file-attributes autoload-file))) 20)
           (car (current-time))))
    (let ((generated-autoload-file autoload-file))
      (message "Updating autoloads...")
      (update-directory-autoloads "~/.emacs.d/")))
(load autoload-file)

;; Autoloads
(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")

(autoload 'git-blame-mode "git-blame" "Minor mode for incremental blame for Git." t)

(autoload 'sml-mode "sml-mode" "Major mode for editing ML programs." t)
(setq auto-mode-alist
      (append '(("\\.sml$" . sml-mode)
                ("\\.sig$" . sml-mode)
                ("\\.ml$"  . sml-mode)
                ("\\.ML$"  . sml-mode)) auto-mode-alist))

(autoload 'w3m "w3m-load" "" t)
(autoload 'lisppaste-paste-region "lisppaste" "" t)

(autoload 'haml-mode "haml-mode" nil t)
(add-to-list 'auto-mode-alist '("\.haml$" . haml-mode))
(autoload 'sass-mode "sass-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode))

(autoload 'php-mode "php-mode" "PHP Editing mode." t)
(add-to-list 'auto-mode-alist '("\.php$" . php-mode))

(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(autoload 'ruby-mode "ruby-mode" "Ruby editing mode." t)
(add-to-list 'auto-mode-alist '("\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\.builder$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))

(add-to-list 'auto-mode-alist '("\.pl$" . prolog-mode))
(add-to-list 'auto-mode-alist '("\.org$" . org-mode))

(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
         (cons '("\\.text" . markdown-mode) auto-mode-alist))
(add-to-list 'auto-mode-alist '("\.markdown$" . markdown-mode))

(autoload 'python-mode
  "python" "Python editing mode." t)

(autoload 'slime-selector "slime" t)

(autoload 'magit-status "magit" nil t)

(load custom-file 'noerror)

;; Personal customizations
(require 'my-faces)
(require 'my-elisp)
(require 'my-bindings)
(require 'my-aliases)
(require 'my-ruby)
(require 'my-hooks)

(if (eq window-system 'mac)
    (load "osx.el")
  (load "linux.el"))

(let ((system-specific-config (concat "~/.emacs.d/hosts/" system-name ".el")))
  (if (file-exists-p system-specific-config)
      (load system-specific-config)))
