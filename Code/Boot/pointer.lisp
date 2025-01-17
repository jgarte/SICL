(cl:in-package #:sicl-boot)

;;; The keys in this table are host objects.  Such an object can be an
;;; instance of HEADER which means that it is an ersatz object, or it
;;; can be an ordinary host object that represents a target object,
;;; such as a symbol or a CONS cell.  The value associated with a key
;;; is a non-negative integer representing the pointer value of the
;;; corresponding object.
(defparameter *host-object-to-pointer-table*
  (make-hash-table :test #'eq))

(defparameter *ersatz-object-table*
  (make-hash-table :test #'eq))

(defun host-char-to-target-code (char)
  #+sb-unicode
  (char-code char)
  #-sb-unicode
  (if (eql char #\Newline)
      10  ; ASCII 10, LF
      (let ((position (position char " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")))
        (if (not (null position))
            (+ 32 position)
            #xfffd)))) ; U+FFFD REPLACEMENT CHARACTER


;;; RACK has been allocated in the simulated heap.  RACK-ADDRESS is
;;; the address in the simulated heap of the rack.  This function
;;; creates work-list items for every entry in the rack.  This action
;;; is valid for all ersatz objects except specialized arrays with
;;; unboxed contents.
(defun handle-unspecialized-rack (rack rack-address)
  (loop for address from rack-address by 8
        for object across rack
        collect (cons address object)))

;;; Allocate the header and the rack of an ersatz object in the
;;; simulated heap.  Write the tagged rack pointer into the second
;;; word of the header.  Return three values: The pointer to the
;;; header, i.e., to the object itself, the raw address of the rack,
;;; and a work-list item for writing the class object into the first
;;; word of the header.
(defun allocate-ersatz-object (object)
  (let* ((header-address (sicl-allocator:allocate-dyad))
         (class (slot-value object '%class))
         (rack (slot-value object '%rack))
         (rack-size (length rack))
         (rack-address (sicl-allocator:allocate-chunk rack-size)))
    ;; Since the rack is not an object in itself, we need to write the
    ;; address of the rack in the memory location corresponding to the
    ;; second word of the header.
    (setf (sicl-memory:memory-unsigned (+ header-address 8) 64)
          (+ rack-address 7))
    (values (+ header-address 5)
            rack-address
            ;; An item to write the class object into the first
            ;; word of the header
            (cons header-address class))))

(defgeneric compute-pointer (object))

(defmethod compute-pointer ((object integer))
  (assert (<= #.(- (expt 2 62)) object #.(1- (expt 2 62))))
  (values (if (minusp object)
              (ash (logand object #.(1- (expt 2 63))) 1)
              (ash object 1))
          '()))

(defmethod compute-pointer ((object character))
  (values (+ (ash (host-char-to-target-code object) 5) #x00011)
          '()))

(defmethod compute-pointer ((object cons))
  (let* ((address (sicl-allocator:allocate-dyad))
         (pointer (1+ address)))
    (setf (gethash object *host-object-to-pointer-table*) pointer)
    (values pointer
            (list (cons address (car object))
                  (cons (+ address 8) (cdr object))))))

(defmethod compute-pointer ((object header))
  (multiple-value-bind (pointer rack-address class-item)
      (allocate-ersatz-object object)
    (setf (gethash object *host-object-to-pointer-table*) pointer)
    (let ((class (slot-value object '%class))
          (rack (slot-value object '%rack))
          (find-class (env:fdefinition (env:client *e5*) *e5* 'find-class)))
      (cond ((eq class (funcall find-class 'sicl-array:vector-unsigned-byte-8))
             ;; The rack contains octets packed so that there are 8
             ;; octets per rack element.  We start by transferring
             ;; those 64-bit words directly to simulated memory.  We
             ;; skip the 3 first elements which must be processed as
             ;; objects.
             (loop for index from 3 below (length rack)
                   for address from (+ rack-address 24) by 8
                   do (setf (sicl-memory:memory-unsigned address 64)
                            (aref rack index)))
             (list class-item
                   (cons rack-address (aref rack 0))
                   (cons (+ rack-address 8) (aref rack 1))
                   (cons (+ rack-address 16) (aref rack 2))))
            ((eq class (funcall find-class 'bit-vector))
             (error "can't handle bit vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-complex-double-float))
             (error "can't handle complex double float vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-complex-single-float))
             (error "can't handle complex single float vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-double-float))
             (error "can't handle double float vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-single-float))
             (error "can't handle single float vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-signed-byte-64))
             (error "can't handle signed byte 64 vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-signed-byte-32))
             (error "can't handle signed byte 32 vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-unsigned-byte-64))
             (error "can't handle unsigned byte 64 vectors"))
            ((eq class (funcall find-class 'sicl-array:vector-unsigned-byte-32))
             (error "can't handle unsigned byte 32 vectors"))
            ((eq class (funcall find-class 'sicl-array:array-bit))
             (error "can't handle bit arrays"))
            ((eq class (funcall find-class 'sicl-array:array-complex-double-float))
             (error "can't handle complex double float arrays"))
            ((eq class (funcall find-class 'sicl-array:array-complex-single-float))
             (error "can't handle complex single float arrays"))
            ((eq class (funcall find-class 'sicl-array:array-double-float))
             (error "can't handle double float arrays"))
            ((eq class (funcall find-class 'sicl-array:array-single-float))
             (error "can't handle single float arrays"))
            ((eq class (funcall find-class 'sicl-array:array-signed-byte-64))
             (error "can't handle signed byte 64 arrays"))
            ((eq class (funcall find-class 'sicl-array:array-signed-byte-32))
             (error "can't handle signed byte 32 arrays"))
            ((eq class (funcall find-class 'sicl-array:array-unsigned-byte-64))
             (error "can't handle unsigned byte 64 arrays"))
            ((eq class (funcall find-class 'sicl-array:array-unsigned-byte-32))
             (error "can't handle unsigned byte 32 arrays"))
            ((eq class (funcall find-class 'sicl-array:array-unsigned-byte-32))
             (error "can't handle unsigned byte 32 arrays"))
            ((eq class (funcall find-class 'sicl-array:array-unsigned-byte-8))
             (error "can't handle unsigned byte 8 arrays"))
            (t
             (loop for address from rack-address by 8
                   for element across rack
                   collect (cons address element)))))))

(defmethod compute-pointer ((object string))
  (let* ((ma (env:fdefinition (env:client *e5*) *e5* 'make-array))
         (ersatz-string
           (funcall ma (length object)
                    :element-type 'character
                    :initial-contents
                    (coerce object 'list))))
    (multiple-value-bind (pointer rack-address class-item)
        (allocate-ersatz-object ersatz-string)
      (setf (gethash object *host-object-to-pointer-table*) pointer)
      (cons class-item
            (handle-unspecialized-rack
             (slot-value ersatz-string '%rack) rack-address)))))

(defun compute-pointer-to-clonable-object (clonable-object name)
  (let* ((mi (env:fdefinition (env:client *e5*) *e5* 'make-instance))
         (ersatz-object
           (apply mi name
                  (loop for (initarg reader)
                          in (clonedijk:clone-information clonable-object)
                        collect initarg
                        collect (funcall reader clonable-object)))))
    (multiple-value-bind (pointer rack-address class-item)
        (allocate-ersatz-object ersatz-object)
      (setf (gethash clonable-object *host-object-to-pointer-table*) pointer)
      (cons class-item
            (handle-unspecialized-rack
             (slot-value ersatz-object '%rack) rack-address)))))

(defmethod compute-pointer ((object symbol))
  (let* ((mi (env:fdefinition (env:client *e5*) *e5* 'make-instance))
         (ersatz-symbol
           (funcall mi 'symbol
                    :name (symbol-name object)
                    :package (symbol-package object))))
    (multiple-value-bind (pointer rack-address class-item)
        (allocate-ersatz-object ersatz-symbol)
      (setf (gethash object *host-object-to-pointer-table*) pointer)
      (cons class-item
            (handle-unspecialized-rack
             (slot-value ersatz-symbol '%rack) rack-address)))))

(defmethod compute-pointer ((object package))
  (let ((external-symbols '())
        (internal-symbols '()))
    (do-symbols (symbol object)
      (multiple-value-bind (symbol status)
          (find-symbol (symbol-name symbol) object)
        (case status
          (:internal (push symbol internal-symbols))
          (:external (push symbol external-symbols)))))
    (let* ((mi (env:fdefinition (env:client *e5*) *e5* 'make-instance))
           (ersatz-package
             (funcall mi 'package
                      :name (package-name object)
                      :nicknames (package-nicknames object)
                      :use-list (package-use-list object)
                      :used-by-list (package-used-by-list object)
                      :external-symbols external-symbols
                      :internal-symbols internal-symbols
                      :shadowing-symbols
                      (package-shadowing-symbols object))))
      (multiple-value-bind (pointer rack-address class-item)
          (allocate-ersatz-object ersatz-package)
      (setf (gethash object *host-object-to-pointer-table*) pointer)
      (cons class-item
            (handle-unspecialized-rack
             (slot-value ersatz-package '%rack) rack-address))))))

(defmethod compute-pointer ((object sicl-compiler:code-object))
  (let* ((mi (env:fdefinition (env:client *e5*) *e5* 'make-instance))
         (ersatz-code-object
           (funcall mi 'sicl-compiler:code-object
                    :instructions (sicl-compiler:instructions object)
                    :literals (sicl-compiler:literals object)
                    :call-sites (sicl-compiler:call-sites object)
                    :function-names (sicl-compiler:function-names object))))
    (multiple-value-bind (pointer rack-address class-item)
        (allocate-ersatz-object ersatz-code-object)
      (setf (gethash object *host-object-to-pointer-table*) pointer)
      (cons class-item
            (handle-unspecialized-rack
             (slot-value ersatz-code-object '%rack) rack-address)))))

(defun write-pointer-to-address (address pointer)
  (setf (sicl-memory:memory-unsigned address 64)
        pointer))

(defun process-work-list-items (work-list-items)
  ;; The work list is a list of work-list items.  A work-list item is
  ;; a CONS cell where the CAR is an address (i.e. a fixnum), and the
  ;; CDR is a host object (which can be an ersatz object).  The item
  ;; represents an instruction that the pointer of the object should
  ;; be written to the address.
  (let ((work-list work-list-items))
    (loop until (null work-list)
          do (destructuring-bind (address . object)
                 (pop work-list)
               ;; It is possible that OBJECT already has a pointer
               ;; associated with it.
               (let ((pointer (gethash object *host-object-to-pointer-table*)))
                 (if (null pointer)
                     ;; No luck, we need to compute the pointer.
                     (multiple-value-bind (pointer work-list-items)
                         (compute-pointer object)
                       ;; Computing the pointer may result in more
                       ;; work-list items, so we prepend them to the
                       ;; work-list.
                       (setf work-list (append work-list-items work-list))
                       ;; And write the resulting pointer to the
                       ;; address.
                       (write-pointer-to-address address pointer))
                     ;; We are in luck.  A pointer for the object
                     ;; already exists.  Just write the pointer to the
                     ;; address.
                     (write-pointer-to-address address pointer)))))))

(defun pointer (object)
  ;; Check whether we have already allocated OBJECT in the heap.
  (let ((existing-pointer (gethash object *host-object-to-pointer-table*)))
    (if (null existing-pointer)
        ;; We need to allocate the object and compute the pointer.
        (multiple-value-bind (pointer work-list-items)
            (compute-pointer object)
          ;; Computing the pointer may have resulted in a bunch of
          ;; work-list items that must be processed.
          (process-work-list-items work-list-items)
          ;; Once the work-list has been processed, we are done and we
          ;; can return the computed pointer.
          pointer)
        ;; We are in luck.  We already have a pointer for the object,
        ;; so just return it.
        existing-pointer)))
