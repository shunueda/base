(defgroup leetgo nil
  "LeetCode integration via leetgo CLI."
  :group 'tools)

(defcustom leetgo-directory "~/leetcode"
  "The root directory of your leetgo project."
  :type 'directory
  :group 'leetgo)

(defun leetgo--run-command (command &optional args file-dir silent)
  (unless (executable-find "leetgo")
    (user-error "Error: 'leetgo' binary not found in your PATH"))
  (let ((default-directory (or file-dir (expand-file-name leetgo-directory)))
        (cmd-string (if args
                        (format "leetgo %s %s" command args)
                      (format "leetgo %s" command))))
    (if silent
        ;; Run quietly in the background for picking operations
        (let* ((cmd-args (if args (split-string-and-unquote args) nil))
               (full-args (cons command cmd-args))
               (proc (apply #'start-process "leetgo-process" "*leetgo-log*" "leetgo" full-args)))
          (message "leetgo: Fetching/picking question in background...")
          (set-process-sentinel proc
                                (lambda (process event)
                                  (when (string-match-p "finished" event)
                                    (message "leetgo: Question files generated successfully!")))))
      ;; Fall back to standard compilation mode for test/submit so you see the output buffer
      (compilation-start cmd-string 'compilation-mode))))

(defun leetgo--extract-qid (file-path)
  (when file-path
    (if (string-match "/\\([0-9]+\\)\\." file-path)
        (let ((raw-id (match-string 1 file-path)))
          (number-to-string (string-to-number raw-id)))
      nil)))

(defun leetgo-test-current ()
  (interactive)
  (let* ((file (buffer-file-name))
         (file-dir (and file (file-name-directory file)))
         (qid (leetgo--extract-qid file)))
    (if (and file (string-prefix-p (expand-file-name leetgo-directory) (expand-file-name file)))
        (if qid
            (leetgo--run-command "test" (format "%s -L" qid) file-dir)
          (leetgo--run-command "test" "last -L" file-dir))
      (message "Not in a valid leetgo project file."))))

(defun leetgo-submit-current ()
  (interactive)
  (let* ((file (buffer-file-name))
         (file-dir (and file (file-name-directory file)))
         (qid (leetgo--extract-qid file)))
    (if (and file (string-prefix-p (expand-file-name leetgo-directory) (expand-file-name file)))
        (if qid
            (leetgo--run-command "submit" qid file-dir)
          (leetgo--run-command "submit" "last" file-dir))
      (message "Not in a valid leetgo project file."))))

(defun leetgo-pick ()
  (interactive)
  (let ((qid (read-string "Enter Question ID, Slug, or 'today': " "")))
    (leetgo--run-command "pick" qid (expand-file-name leetgo-directory) t)))

(defun leetgo-pick-with-emacs-fzf ()
  (interactive)
  (let ((cache-file (expand-file-name "~/.config/leetgo/cache/leetcode-questions.json"))
        (default-directory (expand-file-name leetgo-directory))
        (candidates nil))
    (if (not (file-exists-p cache-file))
        (user-error "Error: leetgo cache file not found")
      (with-temp-buffer
        (insert-file-contents cache-file)
        (goto-char (point-min))
        (let ((questions (json-parse-buffer :object-type 'alist)))
          (seq-do (lambda (q)
                    (let ((id (cdr (assoc 'questionFrontendId q)))
                          (slug (cdr (assoc 'titleSlug q)))
                          (title (cdr (assoc 'title q)))
                          (paid-only (cdr (assoc 'isPaidOnly q))))
                      (when (and id slug title (not (eq paid-only :true)))
                        (push (format "%s: %s - %s" id slug title) candidates))))
                  questions)))
      (let ((selection (completing-read "Select LeetCode Question (Free only): " (nreverse candidates))))
        (when (and selection (not (string-empty-p selection)))
          (if (string-match "^[^:]+:[ \t]*\\([^ ]+\\)" selection)
              (let ((qid (match-string 1 selection)))
                (leetgo--run-command "pick" qid default-directory t))
            (message "Invalid selection.")))))))

(provide 'leetgo)
