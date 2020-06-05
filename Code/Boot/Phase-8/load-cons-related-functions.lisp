(cl:in-package #:sicl-boot-phase-8)

(defun load-cons-related-functions (e5)
  (load-source "Cons/null-defun.lisp" e5)
  (load-source "Cons/endp-defun.lisp" e5)
  ;; Currently, CONSP is defined to be (TYPEP ... 'CONS) and TYPEP
  ;; starts by calling CONSP to determine whether the type specifier
  ;; is atomic or compound.  So if we define CONSP that way, we get
  ;; an infinite recursion.
  ;; (load-source "Cons/consp-defun.lisp" e5)
  (load-source "Cons/listp-defun.lisp" e5)
  (load-source "Cons/list-defun.lisp" e5)
  (load-source "Cons/list-star-defun.lisp" e5)
  (import-function-from-host 'cleavir-code-utilities:parse-macro e5)
  (load-source "Cons/with-proper-list-elements-defmacro.lisp" e5)
  (load-source "Cons/with-proper-list-rests-defmacro.lisp" e5)
  (load-source "Cons/set-difference-defun.lisp" e5)
  (load-source "Cons/nset-difference-defun.lisp" e5)
  (load-source "Cons/adjoin-defun.lisp" e5)
  (load-source "Cons/append-defun.lisp" e5)
  (load-source "Cons/nth-defun.lisp" e5)
  (load-source "Cons/nthcdr-defun.lisp" e5)
  (load-source "Cons/copy-list-defun.lisp" e5)
  (load-source "Cons/with-alist-elements-defmacro.lisp" e5)
  (load-source "Cons/assoc-defun.lisp" e5)
  (load-source "Cons/make-list-defun.lisp" e5)
  (load-source "Cons/last-defun.lisp" e5)
  (load-source "Cons/butlast-defun.lisp" e5)
  (load-source "Cons/union-defun.lisp" e5)
  (load-source "Cons/set-exclusive-or-defun.lisp" e5)
  (load-source "Cons/mapcar-defun.lisp" e5)
  (load-source "Cons/mapc-defun.lisp" e5)
  (load-source "Cons/mapcan-defun.lisp" e5)
  (load-source "Cons/mapcon-defun.lisp" e5))