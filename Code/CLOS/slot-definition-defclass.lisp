(cl:in-package #:sicl-clos)

;;; For the specification of this generic function, see
;;; http://metamodular.com/CLOS-MOP/slot-definition-name.html
(defgeneric slot-definition-name (slot-definition))

(defclass slot-definition (metaobject)
  ((%name 
    :initarg :name
    :reader slot-definition-name)
   (%allocation 
    :initarg :allocation
    :initform :instance
    :reader slot-definition-allocation)
   (%type 
    :initarg :type
    :initform t
    :reader slot-definition-type)
   (%initargs 
    :initform '()
    :initarg :initargs 
    :reader slot-definition-initargs)
   (%initform 
    :initarg :initform 
    :initform nil
    :reader slot-definition-initform)
   (%initfunction 
    :initform nil
    :initarg :initfunction
    :reader slot-definition-initfunction)))
