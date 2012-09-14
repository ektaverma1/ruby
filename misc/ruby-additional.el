;; missing functions in Emacs 24.

(eval-after-load "\\(\\`\\|/\\)ruby-mode\\.elc?\\(\\.gz\\)?\\'"
  (progn
    (define-key ruby-mode-map "\C-c\C-e" 'ruby-insert-end)
    (define-key ruby-mode-map "\C-c{" 'ruby-toggle-block)

    (defun ruby-insert-end ()
      (interactive)
      (if (eq (char-syntax (char-before)) ?w)
	  (insert " "))
      (insert "end")
      (save-excursion
	(if (eq (char-syntax (char-after)) ?w)
	    (insert " "))
	(ruby-indent-line t)
	(end-of-line)))

    (defun ruby-brace-to-do-end ()
      (when (looking-at "{")
	(let ((orig (point)) (end (progn (ruby-forward-sexp) (point))))
	  (when (eq (char-before) ?\})
	    (delete-char -1)
	    (if (eq (char-syntax (char-before)) ?w)
		(insert " "))
	    (insert "end")
	    (if (eq (char-syntax (char-after)) ?w)
		(insert " "))
	    (goto-char orig)
	    (delete-char 1)
	    (if (eq (char-syntax (char-before)) ?w)
		(insert " "))
	    (insert "do")
	    (when (looking-at "\\sw\\||")
	      (insert " ")
	      (backward-char))
	    t))))

    (defun ruby-do-end-to-brace ()
      (when (and (or (bolp)
		     (not (memq (char-syntax (char-before)) '(?w ?_))))
		 (looking-at "\\<do\\(\\s \\|$\\)"))
	(let ((orig (point)) (end (progn (ruby-forward-sexp) (point))))
	  (backward-char 3)
	  (when (looking-at ruby-block-end-re)
	    (delete-char 3)
	    (insert "}")
	    (goto-char orig)
	    (delete-char 2)
	    (insert "{")
	    (if (looking-at "\\s +|")
		(delete-char (- (match-end 0) (match-beginning 0) 1)))
	    t))))

    (defun ruby-toggle-block ()
      (interactive)
      (or (ruby-brace-to-do-end)
	  (ruby-do-end-to-brace)))
    ))