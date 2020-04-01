(cl:in-package #:sicl-boot-phase-6)

(defun tie-code-object (client code-object e1 e2)
  (let* ((hir (sicl-compiler:hir code-object))
         (constants (sicl-compiler:constants code-object))
         (function-names (sicl-compiler:function-names code-object))
         (fun (sicl-hir-interpreter:top-level-hir-to-host-function client hir))
         (sicl-run-time:*dynamic-environment* '()))
    (funcall fun
             (apply #'vector
                    (funcall (sicl-genv:fdefinition 'make-instance e2)
                             'sicl-compiler:code-object
                             :instructions (sicl-compiler:instructions code-object)
                             :frame-maps nil
                             :callee-saves-register-maps nil
                             :callee-saves-stack-maps nil)
                    (labels ((enclose (entry-point code-object &rest static-environment-values)
                               (let* ((static-environment
                                        (apply #'vector
                                               code-object
                                               #'enclose
                                               #'cons
                                               nil
                                               static-environment-values))
                                      (closure (funcall (sicl-genv:fdefinition 'make-instance e2)
                                                        'sicl-clos:simple-function
                                                        :environment static-environment)))
                                 (closer-mop:set-funcallable-instance-function
                                  closure
                                  (lambda (&rest args)
                                    (funcall entry-point
                                             args
                                             static-environment
                                             sicl-run-time:*dynamic-environment*)))
                                 closure)))
                      #'enclose)
                    #'cons
                    nil
                    (append (loop for name in function-names
                                  collect (sicl-genv:function-cell name e1))
                            constants)))))))

(defun load-fasl (relative-pathname global-environment)
  (format *trace-output* "Loading file ~s~%" relative-pathname)
  (let* ((client (make-instance 'sicl-boot:client))
         (prefixed (concatenate 'string "ASTs/" relative-pathname))
         (pathname (asdf:system-relative-pathname '#:sicl-boot prefixed))
         (ast (cleavir-io:read-model pathname '(v0)))
         (hir (sicl-ast-to-hir:ast-to-hir client ast))
         (hir2 (sicl-ast-to-hir:ast-to-hir client ast))
         (fun (sicl-hir-interpreter:top-level-hir-to-host-function client hir))
         (sicl-run-time:*dynamic-environment* '()))
    (sicl-hir-transformations:eliminate-append-values-instructions hir2)
    (sicl-hir-to-mir:hir-to-mir client hir2)
    (sicl-mir-to-lir:mir-to-lir client hir2)
    (multiple-value-bind (instructions label-map)
        (cluster:assemble (sicl-code-generation:generate-code hir2))
      (declare (ignore label-map))
      (funcall fun
               (apply #'vector
                      (funcall (sicl-genv:fdefinition 'make-instance sicl-boot:*e5*)
                               'sicl-compiler:code-object
                               :instructions instructions
                               :frame-maps nil
                               :callee-saves-register-maps nil
                               :callee-saves-stack-maps nil)
                      (labels ((enclose (entry-point code-object &rest static-environment-values)
                                 (let* ((static-environment
                                          (apply #'vector
                                                 code-object
                                                 #'enclose
                                                 #'cons
                                                 nil
                                                 static-environment-values))
                                        (closure (funcall (sicl-genv:fdefinition 'make-instance sicl-boot:*e5*)
                                                          'sicl-clos:simple-function
                                                          :environment static-environment)))
                                   (closer-mop:set-funcallable-instance-function
                                    closure
                                    (lambda (&rest args)
                                      (funcall entry-point
                                               args
                                               static-environment
                                               sicl-run-time:*dynamic-environment*)))
                                   closure)))
                        #'enclose)
                      #'cons
                      nil
                      (append (loop with names = (sicl-hir-transformations:function-names hir)
                                    for name in names
                                    collect (sicl-genv:function-cell name global-environment))
                              (sicl-hir-transformations:constants hir)))))))
