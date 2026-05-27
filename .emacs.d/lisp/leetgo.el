(defgroup leetgo nil
  "Comfortable LeetCode integration via leetgo CLI."
  :group 'tools)

(defcustom leetgo-directory "~/leetcode"
  "The root directory of your leetgo project (where leetgo.yaml sits)."
  :type 'directory
  :group 'leetgo)

(defun leetgo--run-command (command &optional args file-dir)
  (unless (executable-find "leetgo")
    (user-error "Error: 'leetgo' binary not found in your PATH"))
  (let ((default-directory (or file-dir (expand-file-name leetgo-directory)))
        (cmd-string (if args
                        (format "leetgo %s %s" command args)
                      (format "leetgo %s" command))))
    (compilation-start cmd-string 'compilation-mode)))

(defun leetgo--extract-qid (file-path)
  (when file-path
    (if (string-match "/\\([0-9]+\\)\\." file-path)
        (let ((raw-id (match-string 1 file-path)))
          (number-to-string (string-to-number raw-id)))
      nil)))

;;;###autoload
(defun leetgo-pick ()
  (interactive)
  (let ((qid (read-string "Enter Question ID, Slug, or 'today': " "")))
    (leetgo--run-command "pick" qid (expand-file-name leetgo-directory))))

;;;###autoload
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

;;;###autoload
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

(provide 'leetgo)
