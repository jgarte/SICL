(cl:in-package #:cleavir-ast)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class OPTIMIZE-AST.

(defclass optimize-ast (ast)
  ((%child-ast :initarg :child-ast :reader child-ast)
   (%value-ast :initarg :value-ast :reader value-ast)))

(cleavir-io:define-save-info optimize-ast
  (:child-ast child-ast)
  (:value-ast value-ast))

(defmethod children ((ast optimize-ast))
  (list (child-ast ast)))
