;; -*- coding: utf-8 -*-

(defun xah-delete-current-line ()
  "Delete current line."
  (interactive)
  (delete-region (line-beginning-position) (line-end-position))
  (when (looking-at "\n")
    (delete-char 1)))

(defun xah-copy-line-or-region ()
  "Copy current line, or text selection.
When `universal-argument' is called first, copy whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2015-05-06"
  (interactive)
  (let (ξp1 ξp2)
    (if current-prefix-arg
        (progn (setq ξp1 (point-min))
               (setq ξp2 (point-max)))
      (progn (if (use-region-p)
                 (progn (setq ξp1 (region-beginning))
                        (setq ξp2 (region-end)))
               (progn (setq ξp1 (line-beginning-position))
                      (setq ξp2 (line-end-position))))))
    (kill-ring-save ξp1 ξp2)
    (if current-prefix-arg
        (message "buffer text copied")
      (message "text copied"))))

(defun xah-cut-line-or-region ()
  "Cut current line, or text selection.
When `universal-argument' is called first, cut whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2015-06-10"
  (interactive)
  (if current-prefix-arg
      (progn ; not using kill-region because we don't want to include previous kill
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (progn (if (use-region-p)
               (kill-region (region-beginning) (region-end) t)
             (kill-region (line-beginning-position) (line-beginning-position 2))))))

(defun xah-copy-all ()
  "Put the whole buffer content into the `kill-ring'.
(respects `narrow-to-region')
URL `http://ergoemacs.org/emacs/elisp_cut_copy_yank_kill-ring.html'
Version 2015-05-06"
  (interactive)
  (kill-new (buffer-string))
  (message "Buffer content copied."))

(defun xah-cut-all ()
  "Cut the whole buffer content into the `kill-ring'. (respects `narrow-to-region')"
  (interactive)
  (kill-new (buffer-string))
  (delete-region (point-min) (point-max)))



(defun xah-toggle-letter-case (φbegin φend)
  "Toggle the letter case of current word or text selection.
Always cycle in this order: Init Caps, ALL CAPS, all lower.

In lisp code, φbegin φend are region boundary.
URL `http://ergoemacs.org/emacs/modernization_upcase-word.html'
Version 2015-04-09"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (let ((ξbds (bounds-of-thing-at-point 'word)))
       (list (car ξbds) (cdr ξbds)))))
  (let ((deactivate-mark nil))
    (when (not (eq last-command this-command))
      (put this-command 'state 0))
    (cond
     ((equal 0 (get this-command 'state))
      (upcase-initials-region φbegin φend)
      (put this-command 'state 1))
     ((equal 1  (get this-command 'state))
      (upcase-region φbegin φend)
      (put this-command 'state 2))
     ((equal 2 (get this-command 'state))
      (downcase-region φbegin φend)
      (put this-command 'state 0)))))

(defun xah-toggle-previous-letter-case ()
  "Toggle the letter case of the letter to the left of cursor."
  (interactive)
  (let ((case-fold-search nil))
    (left-char 1)
    (cond
     ((looking-at "[[:lower:]]") (upcase-region (point) (1+ (point))))
     ((looking-at "[[:upper:]]") (downcase-region (point) (1+ (point)))))
    (right-char)))



(defun xah-shrink-whitespaces-old-2015-03-03 ()
  "Remove whitespaces around cursor to just one or none.
If current line does have visible characters: shrink whitespace around cursor to just one space.
If current line does not have visible chars, then shrink all neighboring blank lines to just one.
If current line is a single space, remove that space.
URL `http://ergoemacs.org/emacs/emacs_shrink_whitespace.html'
Version 2015-03-03"
  (interactive)
  (let ((pos0 (point))
        ξline-has-char-p ; current line contains non-white space chars
        ξhas-space-tab-neighbor-p
        ξwhitespace-begin ξwhitespace-end
        ξspace-or-tab-begin ξspace-or-tab-end
        )
    (save-excursion
      (setq ξhas-space-tab-neighbor-p (if (or (looking-at " \\|\t") (looking-back " \\|\t")) t nil))
      (beginning-of-line)
      (setq ξline-has-char-p (search-forward-regexp "[[:graph:]]" (line-end-position) t))

      (goto-char pos0)
      (skip-chars-backward "\t ")
      (setq ξspace-or-tab-begin (point))

      (skip-chars-backward "\t \n")
      (setq ξwhitespace-begin (point))

      (goto-char pos0)
      (skip-chars-forward "\t ")
      (setq ξspace-or-tab-end (point))
      (skip-chars-forward "\t \n")
      (setq ξwhitespace-end (point)))

    (if ξline-has-char-p
        (let (ξdeleted-text)
          (when ξhas-space-tab-neighbor-p
            ;; remove all whitespaces in the range
            (setq ξdeleted-text (delete-and-extract-region ξspace-or-tab-begin ξspace-or-tab-end))
            ;; insert a whitespace only if we have removed something different than a simple whitespace
            (if (not (string= ξdeleted-text " "))
                (insert " "))))
      (progn (delete-blank-lines)))))

(defun xah-shrink-whitespaces ()
  "Remove whitespaces around cursor to just one or none.
Remove whitespaces around cursor to just one space, or remove neighboring blank lines to just one or none.
URL `http://ergoemacs.org/emacs/emacs_shrink_whitespace.html'
Version 2015-03-03"
  (interactive)
  (let ((pos0 (point))
        ξline-has-char-p ; current line contains non-white space chars
        ξhas-space-tab-neighbor-p
        ξwhitespace-begin ξwhitespace-end
        ξspace-or-tab-begin ξspace-or-tab-end
        )
    (save-excursion
      (setq ξhas-space-tab-neighbor-p (if (or (looking-at " \\|\t") (looking-back " \\|\t")) t nil))
      (beginning-of-line)
      (setq ξline-has-char-p (search-forward-regexp "[[:graph:]]" (line-end-position) t))

      (goto-char pos0)
      (skip-chars-backward "\t ")
      (setq ξspace-or-tab-begin (point))

      (skip-chars-backward "\t \n")
      (setq ξwhitespace-begin (point))

      (goto-char pos0)
      (skip-chars-forward "\t ")
      (setq ξspace-or-tab-end (point))
      (skip-chars-forward "\t \n")
      (setq ξwhitespace-end (point)))

    (if ξline-has-char-p
        (if ξhas-space-tab-neighbor-p
            (let (ξdeleted-text)
              ;; remove all whitespaces in the range
              (setq ξdeleted-text
                    (delete-and-extract-region ξspace-or-tab-begin ξspace-or-tab-end))
              ;; insert a whitespace only if we have removed something different than a simple whitespace
              (when (not (string= ξdeleted-text " "))
                (insert " ")))

          (progn
            (when (equal (char-before) 10) (delete-char -1))
            (when (equal (char-after) 10) (delete-char 1))))
      (progn (delete-blank-lines)))))

(defun xah-compact-uncompact-block ()
  "Remove or insert newline characters on the current block of text.
This is similar to a toggle for `fill-paragraph' and `unfill-paragraph'.

When there is a text selection, act on the the selection, else, act on a text block separated by blank lines.
Version 2015-06-20"
  (interactive)
  ;; This command symbol has a property “'stateIsCompact-p”, the possible values are t and nil. This property is used to easily determine whether to compact or uncompact, when this command is called again
  (let ( ξis-compact-p
         (deactivate-mark nil)
         (ξblanks-regex "\n[ \t]*\n")
         ξp1 ξp2
         )
    (progn
      (if (use-region-p)
          (progn (setq ξp1 (region-beginning))
                 (setq ξp2 (region-end)))
        (save-excursion
          (if (re-search-backward ξblanks-regex nil "NOERROR")
              (progn (re-search-forward ξblanks-regex)
                     (setq ξp1 (point)))
            (setq ξp1 (point)))
          (if (re-search-forward ξblanks-regex nil "NOERROR")
              (progn (re-search-backward ξblanks-regex)
                     (setq ξp2 (point)))
            (setq ξp2 (point))))))
    (save-excursion
      (setq ξis-compact-p
            (if (eq last-command this-command)
                (get this-command 'stateIsCompact-p)
              (progn
                (goto-char ξp1)
                (if (> (- (line-end-position) (line-beginning-position)) fill-column) t nil))))
      (if ξis-compact-p
          (fill-region ξp1 ξp2)
        (let ((fill-column most-positive-fixnum)) (fill-region ξp1 ξp2)))
      (put this-command 'stateIsCompact-p (if ξis-compact-p nil t)))))

(defun xah-unfill-paragraph ()
  "Replace newline chars in current paragraph by single spaces.
This command does the inverse of `fill-paragraph'."
  (interactive)
  (let ((fill-column 90002000)) ; 90002000 is just random. you can use `most-positive-fixnum'
    (fill-paragraph)))

(defun xah-unfill-region (start end)
  "Replace newline chars in region by single spaces.
This command does the inverse of `fill-region'."
  (interactive "r")
  (let ((fill-column 90002000))
    (fill-region start end)))

(defun xah-replace-newline-whitespaces-to-space (&optional φbegin φend φabsolute-p)
  "Replace newline+tab char sequence to 1 just space, in current text block or selection.
This is similar to `fill-region' but without being smart.
Version 2015-06-09"
  (interactive)
  (let (ξbegin ξend)
    (if (null φbegin)
        (if (use-region-p)
            (progn (setq ξbegin (region-beginning)) (setq ξend (region-end)))
          (save-excursion
            (if (re-search-backward "\n[ \t]*\n" nil "NOERROR")
                (progn (re-search-forward "\n[ \t]*\n")
                       (setq ξbegin (point)))
              (setq ξbegin (point)))
            (if (re-search-forward "\n[ \t]*\n" nil "NOERROR")
                (progn (re-search-backward "\n[ \t]*\n")
                       (setq ξend (point)))
              (setq ξend (point)))))
      (progn (setq ξbegin φbegin) (setq ξend φend)))
    (save-excursion
      (save-restriction
        (narrow-to-region ξbegin ξend)
        (goto-char (point-min))
        (while (search-forward-regexp "\n[ \t]*\n" nil t) (replace-match "\n\n"))
        (goto-char (point-min))
        (while (search-forward-regexp "[ \t]*\n[ \t]*" nil t) (replace-match "\n"))
        (goto-char (point-min))
        (while (search-forward-regexp "\n\n+" nil t) (replace-match "hqnvdr9b35"))
        (goto-char (point-min))
        (while (search-forward-regexp "\n" nil t) (replace-match " "))
        (goto-char (point-min))
        (while (search-forward "hqnvdr9b35" nil t) (replace-match "\n\n"))))))

(defun xah-cycle-hyphen-underscore-space ()
  "Cycle {underscore, space, hypen} chars of current word or text selection.
When called repeatedly, this command cycles the {“_”, “-”, “ ”} characters, in that order.

URL `http://ergoemacs.org/emacs/elisp_change_space-hyphen_underscore.html'
Version 2015-08-17"
  (interactive)
  ;; this function sets a property 「'state」. Possible values are 0 to length of ξcharArray.
  (let (ξp1 ξp2)
    (if (use-region-p)
        (progn 
          (setq ξp1 (region-beginning))
          (setq ξp2 (region-end)))
      (let ((ξbounds (bounds-of-thing-at-point 'symbol)))
        (progn
          (setq ξp1 (car ξbounds))
          (setq ξp2 (cdr ξbounds)))))

    (let* ((ξinputText (buffer-substring-no-properties ξp1 ξp2))
           (ξcharArray ["_" "-" " "])
           (ξlength (length ξcharArray))
           (ξregionWasActive-p (region-active-p))
           (ξnowState
            (if (equal last-command this-command )
                (get 'xah-cycle-hyphen-underscore-space 'state)
              0 ))
           (ξchangeTo (elt ξcharArray ξnowState)))
      (save-excursion
        (save-restriction
          (narrow-to-region ξp1 ξp2)
          (goto-char (point-min))
          (while
              (search-forward-regexp
               (concat
                (elt ξcharArray (% (+ ξnowState 1) ξlength))
                "\\|"
                (elt ξcharArray (% (+ ξnowState 2) ξlength)))
               (point-max)
               'NOERROR)
            (replace-match ξchangeTo 'FIXEDCASE 'LITERAL))))
      (when (or (string= ξchangeTo " ") ξregionWasActive-p)
        (goto-char ξp2)
        (set-mark ξp1)
        (setq deactivate-mark nil))
      (put 'xah-cycle-hyphen-underscore-space 'state (% (+ ξnowState 1) ξlength)))))

(defun xah-underscore-to-space-region (φbegin φend)
  "Change  underscore char to space.
URL `http://ergoemacs.org/emacs/elisp_change_space-hyphen_underscore.html'
Version 2015-08-18"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region φbegin φend)
      (goto-char (point-min))
      (while
          (search-forward-regexp "_" (point-max) 'NOERROR)
        (replace-match " " 'FIXEDCASE 'LITERAL)))))



(defun xah-copy-file-path (&optional φdir-path-only-p)
  "Copy the current buffer's file path or dired path to `kill-ring'.
If `universal-argument' is called first, copy only the dir path.
URL `http://ergoemacs.org/emacs/emacs_copy_file_path.html'
Version 2015-08-08"
  (interactive "P")
  (let ((ξfpath
         (if (equal major-mode 'dired-mode)
             default-directory
           (if (null (buffer-file-name))
               (user-error "Current buffer is not associated with a file.")
             (buffer-file-name)))))
    (kill-new
     (if (null φdir-path-only-p)
         (progn
           (message "File path copied: 「%s」" ξfpath)
           ξfpath
           )
       (progn
         (message "Directory path copied: 「%s」" (file-name-directory ξfpath))
         (file-name-directory ξfpath))))))

(defun xah-delete-text-block ()
  "delete the current text block (paragraph) and also put it to `kill-ring'.
Version 2015-05-26"
  (interactive)
  (let (p1 p2)
    (progn
      (if (re-search-backward "\n[ \t]*\n" nil "NOERROR")
          (progn (re-search-forward "\n[ \t]*\n")
                 (setq p1 (point)))
        (setq p1 (point)))
      (if (re-search-forward "\n[ \t]*\n" nil "NOERROR")
          (progn (re-search-backward "\n[ \t]*\n")
                 (setq p2 (point)))
        (setq p2 (point))))
    (kill-region p1 p2)))

(defun xah-copy-to-register-1 ()
  "Copy current line or text selection to register 1.
See also: `xah-paste-from-register-1', `copy-to-register'."
  (interactive)
  (let (p1 p2)
    (if (region-active-p)
        (progn (setq p1 (region-beginning))
               (setq p2 (region-end)))
      (progn (setq p1 (line-beginning-position))
             (setq p2 (line-end-position))))
    (copy-to-register ?1 p1 p2)
    (message "copied to register 1: 「%s」." (buffer-substring-no-properties p1 p2))))

(defun xah-paste-from-register-1 ()
  "Paste text from register 1.
See also: `xah-copy-to-register-1', `insert-register'."
  (interactive)
  (when (use-region-p)
    (delete-region (region-beginning) (region-end) )
    )
  (insert-register ?1 t))



(defun xah-copy-rectangle-to-clipboard (φbegin φend)
  "Copy region as column (rectangle) to operating system's clipboard.
This command will also put the text in register 0.

See also: `kill-rectangle', `copy-to-register'."
  (interactive "r")
  (let ((x-select-enable-clipboard t))
    (copy-rectangle-to-register ?0 φbegin φend)
    (kill-new
     (with-temp-buffer
       (insert-register ?0)
       (buffer-string) ))))



(defun xah-upcase-sentence ()
  "Upcase sentence.
TODO 2014-09-30 command incomplete
"
  (interactive)
  (let (p1 p2)

    (if (region-active-p)
        (progn
          (setq p1 (region-beginning))
          (setq p2 (region-end)))
      (progn
        (save-excursion
          (progn
            (if (re-search-backward "\n[ \t]*\n" nil "move")
                (progn (re-search-forward "\n[ \t]*\n")
                       (setq p1 (point)))
              (setq p1 (point)))
            (if (re-search-forward "\n[ \t]*\n" nil "move")
                (progn (re-search-backward "\n[ \t]*\n")
                       (setq p2 (point)))
              (setq p2 (point)))))))

    (save-excursion
      (save-restriction
        (narrow-to-region p1 p2)

        (goto-char (point-min))
        (while (search-forward "\. \{1,2\}\\([a-z]\\)" nil t)
nil
;; (replace-match "myReplaceStr2")

)))))

(defun xah-escape-quotes (φbegin φend)
  "Replace 「\"」 by 「\\\"」 in current line or text selection.
See also: `xah-unescape-quotes'
URL `http://ergoemacs.org/emacs/elisp_escape_quotes.html'
Version 2015-05-04"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (line-beginning-position) (line-end-position))))
  (save-excursion
      (save-restriction
        (narrow-to-region φbegin φend)
        (goto-char (point-min))
        (while (search-forward "\"" nil t)
          (replace-match "\\\"" 'FIXEDCASE 'LITERAL)))))

(defun xah-unescape-quotes (φbegin φend)
  "Replace  「\\\"」 by 「\"」 in current line or text selection.
See also: `xah-escape-quotes'
URL `http://ergoemacs.org/emacs/elisp_escape_quotes.html'
Version 2015-05-04"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (line-beginning-position) (line-end-position))))
  (save-excursion
    (save-restriction
      (narrow-to-region φbegin φend)
      (goto-char (point-min))
      (while (search-forward "\\\"" nil t)
        (replace-match "\"" 'FIXEDCASE 'LITERAL)))))

(defun xah-title-case-region-or-line (φbegin φend)
  "Title case text between nearest brackets, or current line, or text selection.
Capitalize first letter of each word, except words like {to, of, the, a, in, or, and, …}. If a word already contains cap letters such as HTTP, URL, they are left as is.

When called in a elisp program, φbegin φend are region boundaries.
URL `http://ergoemacs.org/emacs/elisp_title_case_text.html'
Version 2015-05-07"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (let (
           ξp1
           ξp2
           (ξskipChars "^\"<>(){}[]“”‘’‹›«»「」『』【】〖〗《》〈〉〔〕"))
       (progn
         (skip-chars-backward ξskipChars (line-beginning-position))
         (setq ξp1 (point))
         (skip-chars-forward ξskipChars (line-end-position))
         (setq ξp2 (point)))
       (list ξp1 ξp2))))
  (let* (
         (ξstrPairs [
                     [" A " " a "]
                     [" And " " and "]
                     [" At " " at "]
                     [" As " " as "]
                     [" By " " by "]
                     [" Be " " be "]
                     [" Into " " into "]
                     [" In " " in "]
                     [" Is " " is "]
                     [" It " " it "]
                     [" For " " for "]
                     [" Of " " of "]
                     [" Or " " or "]
                     [" On " " on "]
                     [" Via " " via "]
                     [" The " " the "]
                     [" That " " that "]
                     [" To " " to "]
                     [" Vs " " vs "]
                     [" With " " with "]
                     [" From " " from "]
                     ["'S " "'s "]
                     ]))
    (save-excursion
      (save-restriction
        (narrow-to-region φbegin φend)
        (upcase-initials-region (point-min) (point-max))
        (let ((case-fold-search nil))
          (mapc
           (lambda (ξx)
             (goto-char (point-min))
             (while
                 (search-forward (aref ξx 0) nil t)
               (replace-match (aref ξx 1) 'FIXEDCASE 'LITERAL)))
           ξstrPairs))))))