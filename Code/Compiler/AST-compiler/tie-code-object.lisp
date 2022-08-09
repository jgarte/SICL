(cl:in-package #:sicl-compiler)

(defun source-position-equal (p1 p2)
  (and (eql (sicl-source-tracking:line-index (car p1))
            (sicl-source-tracking:line-index (car p2)))
       (eql (sicl-source-tracking:line-index (cdr p1))
            (sicl-source-tracking:line-index (cdr p2)))
       (eql (sicl-source-tracking:character-index (car p1))
            (sicl-source-tracking:character-index (car p2)))
       (eql (sicl-source-tracking:character-index (cdr p1))
            (sicl-source-tracking:character-index (cdr p2)))
       (equalp (sicl-source-tracking:lines (car p1))
               (sicl-source-tracking:lines (car p2)))))

;;; FIXME: This code should be the native version of TIE-CODE-OBJECT,
;;; but it is not.
(defun tie-code-object (client environment code-object hir-thunks)
  (let ((sicl-run-time:*dynamic-environment* '())
        (function-cell-function
          (env:fdefinition
           client environment 'sicl-data-and-control-flow:function-cell))
        (who-calls-information
          (env:who-calls-information environment)))
    (loop for call-site in (call-sites code-object)
          for instruction = (instruction call-site)
          when (typep instruction 'sicl-ir:named-call-instruction)
            do (let ((cell (sicl-ir:function-cell-cell instruction))
                     (name (name call-site)))
                 (let ((origin (cleavir-ast-to-hir:origin instruction)))
                   (unless (null origin)
                     (pushnew origin (gethash name who-calls-information '())
                              :test #'source-position-equal)))
                 (setf (car cell)
                       (funcall function-cell-function name))))
    (funcall hir-thunks)))
