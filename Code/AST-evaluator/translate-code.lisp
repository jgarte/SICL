(cl:in-package #:sicl-ast-evaluator)

(defclass client (trucler-reference:client)
  ())

(defun translate-code (code environment)
  (let* ((cst (cst:cst-from-expression code))
         (client (make-instance 'client))
         (ast (cleavir-cst-to-ast:cst-to-ast
               client cst environment))
         (table (make-hash-table :test #'eq))
         (lexical-environment (list table)))
    (translate-ast ast environment lexical-environment)))