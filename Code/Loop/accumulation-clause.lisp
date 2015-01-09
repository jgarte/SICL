;;;; Copyright (c) 2015
;;;;
;;;;     Robert Strandh (robert.strandh@gmail.com)
;;;;
;;;; all rights reserved. 
;;;;
;;;; Permission is hereby granted to use this software for any 
;;;; purpose, including using, modifying, and redistributing it.
;;;;
;;;; The software is provided "as-is" with no warranty.  The user of
;;;; this software assumes any responsibility of the consequences. 

(cl:in-package #:sicl-loop)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Accumulation clauses

(defclass accumulation-clause (selectable-clause)
  ())

;;; The methods on ACCUMULATION-VARIABLES call the function INTO-VAR
;;; on the clause in order to obtain the first element of each
;;; accumulation variable descriptor.  For clauses that have
;;; INTO-MIXIN as a superclass, the variable is stored in a slot.
;;; This method defines the default method to be used for all other
;;; accumulation clauses.
(defmethod into-var ((clause accumulation-clause))
  'nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; LIST-ACCUMULATION-CLAUSE.
;;;
;;; This class is the superclass of the list accumulation clauses:
;;; COLLECT-CLAUSE, APPEND-CLAUSE, and NCONC-CLAUSE.
;;;

(defclass list-accumulation-clause (accumulation-clause) ())

;;; The methods on ACCUMULATION-VARIABLES call the function TYPE-SPEC
;;; on the clause in order to obtain the third element of each
;;; accumulation variable descriptor.  For the numeric accumulation
;;; clauses, the type is stored in a slot.  For the list accumulation
;;; clauses, we always want to return the type LIST.
(defmethod type-spec ((clause list-accumulation-clause))
  'list)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; NUMERIC-ACCUMULATION-CLAUSE.

(defclass numeric-accumulation-clause (accumulation-clause)
  ((%type-spec :initform T :initarg :type-spec :reader type-spec)))

(defclass count/sum-accumulation-clause (numeric-accumulation-clause) ())

(defclass max/min-accumulation-clause (numeric-accumulation-clause) ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Mixin class for INTO clause variants.

(defclass into-mixin ()
  ((%into-var :initform nil :initarg :into-var :accessor into-var)))

