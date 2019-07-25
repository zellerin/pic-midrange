(defun main ()
  (with-open-file (in (merge-pathnames "1855.asm" (or #.*load-pathname*)))
    (loop for line = (read-line in nil)
	  while line
	  when (parsed-line line)
	    collect it)))

(defun parsed-line (line)
  (loop for pattern in '("^$"
			 "^;;;+ *(.*)"
			 "^([a-z_0-9]+):? *$"
			 (:sequence
			  ;; label
			  (:greedy-repetition 0 1
			   (:sequence
			    (:register
			     (:greedy-repetition 1 nil :non-whitespace-char-class))
			    (:greedy-repetition 0 1 #\:)))
			  (:greedy-repetition 1 nil :whitespace-char-class)
					;op
			  (:register
			   (:greedy-repetition 1 nil :non-whitespace-char-class))
			  (:greedy-repetition 0 nil :whitespace-char-class)
			  (:greedy-repetition 0 1
			   (:sequence
			    (:register
			     (:regex "0x[0-9a-fA-F][0-9a-fA-F]"))))
			  (:greedy-repetition 0 1
			   (:sequence
			    #\,
			    (:greedy-repetition 1 nil :whitespace-char-class)
			    (:register
			     (:regex "0x[0-9a-f][0-9a-f]"))))
			  (:greedy-repetition 0 nil :whitespace-char-class)
			  (:greedy-repetition 0 1
			   (:sequence
			    #\;
			    (:greedy-repetition 1 nil :whitespace-char-class)
			    (:register
			     (:regex ".*$")))))
			 "(.*)")
	and prefix in '(empty-line
			line-comment
			label
			command
			unknown)
	for parsed = (map 'list
			  'identity
			  (nth-value 1 (cl-ppcre:scan-to-strings pattern line)))
	when parsed
	  do (return (list* prefix parsed))))
