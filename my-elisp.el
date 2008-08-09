(defun my-mark-word ()
  "Marks the whole word the cursor is placed on"
  (interactive)
  (backward-word)
  (mark-word))

(defun conservative-editing ()
  "For working on other peoples source - turn off hooks etc. TODO place this in a minor mode"
  (interactive)
  (remove-hook 'write-file-hooks 'delete-trailing-whitespace)
  (remove-hook 'write-contents-hooks 'untabify-buffer)
  (local-set-key [return] 'newline-and-indent))

(defun disable-conservative-editing ()
  (interactive)
  (add-hook 'write-file-hooks 'delete-trailing-whitespace)
  (add-hook 'write-contents-hooks 'untabify-buffer)
  (local-set-key [return] 'reindent-then-newline-and-indent))

;; TODO fix this, probably tramp issue
(defun find-alternative-file-with-sudo ()
  (interactive)
  (when buffer-file-name
    (find-alternate-file
     (concat "/sudo:root@localhost:"
             buffer-file-name))))

(defun my-eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun my-print-macro-expansion ()
  "insert the expansion of a macro"
  (interactive)
  (backward-kill-sexp)
  (undo)
  (insert (concat "\n" (pp (cl-macroexpand (read (current-kill 0)))))))

;; TODO make this more general and use run-shell-command instead with sed etc
;; so the buffer doesn't get modified
(defun line-count-lisp ()
  (interactive)
  (save-excursion
    (flush-lines "^$")
    (flush-lines "^;")
    (goto-char (point-max))
    (let ((loc (line-number-at-pos)))
      (message (number-to-string loc) " lines of code. Be sure to undo now."))))

;; From Steve Yegge
(defun article-length ()
  "Print character and word stats on current buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((char-count 0))
      (while (not (eobp))
        (unless (looking-at "[ \t\r\n]")
          (incf char-count))
        (forward-char 1))
      (message "%d chars, %d words" char-count (/ char-count 5)))))

(defun duplicate-line ()
  "Duplicates current line and inserts it below. TODO: keep position & work for regions as well"
  (interactive)
  (beginning-of-line)
  (kill-line)
  (yank)
  (newline)
  (yank)
  (end-of-line))

(defun insert-line-below ()
  "Inserts a new line below cursor"
  (interactive)
  (end-of-line)
  (newline-and-indent))

;; Taken from http://emacs.wordpress.com/2007/01/22/killing-yanking-and-copying-lines/
(defun jao-copy-line ()
  "Copy current line in the kill ring"
  (interactive)
  (kill-ring-save (line-beginning-position)
                  (line-beginning-position 2))
  (message "Line copied"))

(defun mark-line (&optional arg)
  "Marks a line from start of indentation to end"
  (interactive "p")
  (back-to-indentation)
  (end-of-line-mark arg))

(defun file2url ()
  "Uploads the file in the current buffer via file2url.sh, displays the resulting url."
  (interactive)
  (message "%s"
           (shell-command-to-string
            (concatenate 'string "file2url.sh " buffer-file-name))))

(defun indent-buffer ()
  "Indent whole buffer"
  (interactive)
  (save-excursion (indent-region (point-min) (point-max) nil)))

(defun untabify-buffer ()
  "Untabify the whole (accessible part of the) current buffer"
  (interactive)
  (save-excursion (untabify (point-min) (point-max))))

(defun dos2unix ()
  "Convert a buffer from dos ^M end of lines to unix end of lines"
  (interactive)
  (goto-char (point-min))
  (while (search-forward "\r" nil t) (replace-match "")))

(defun load-elisp()
  "Automatic reload current file that major mode is Emacs-Lisp mode."
  (interactive)
  (if (member major-mode '(emacs-lisp-mode)) ;if current major mode is emacs-lisp-mode
      (progn
        (indent-buffer)                      ;format
        (save-buffer)                        ;save
        (byte-compile-file buffer-file-name) ;compile
        (load-file buffer-file-name)         ;loading
        (eval-buffer)                        ;revert
        )
    (message "Current major mode is not Emacs-Lisp mode, so not reload.") ;otherwise don't loading
    ))

(defun word-count ()
  "Count words in buffer"
  (interactive)
  (shell-command-on-region (point-min) (point-max) "wc -w"))

(defun shell-here ()
  "Open a shell in `default-directory'."
  (interactive)
  (let ((dir (expand-file-name default-directory))
        (buf (or (get-buffer "*shell*") (shell))))
    (goto-char (point-max))
    (if (not (string= (buffer-name) "*shell*"))
        (switch-to-buffer-other-window buf))
    (message list-buffers-directory)
    (if (not (string= (expand-file-name list-buffers-directory) dir))
        (progn (comint-send-string (get-buffer-process buf)
                                   (concat "cd \"" dir "\"\r"))
               (setq list-buffers-directory dir)))))

(defun delete-empty-pair ()
  "Borrowed from TextMate mode"
  (defun is-empty-pair ()
    (let ((pairs '(( ?\( . ?\))
                   ( ?\' . ?\')
                   ( ?\" . ?\")
                   ( ?[ . ?])
                   ( ?{ . ?}))))
      (eq (cdr (assoc (char-before) pairs)) (char-after))))

  (interactive)
  (if (eq (char-after) nil)
      nil ;; if char-after is nil, just backspace
    (if (is-empty-pair)
        (delete-char 1)))
  (delete-backward-char 1))

(defun set-skeleton-pairs (pairs)
  "Sets multiple skeleton pairs at once"
  (mapcar '(lambda (pair)
             (local-set-key pair 'skeleton-pair-insert-maybe)) pairs)
  (setq skeleton-pair t))

(provide 'my-elisp)
