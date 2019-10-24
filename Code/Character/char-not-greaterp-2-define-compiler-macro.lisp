(cl:in-package #:sicl-character)

(define-compiler-macro char-not-greaterp (&whole form &rest arguments)
  (cond ((not (and (cleavir-code-utilities:proper-list-p arguments)
               (>= (length arguments) 1)))
         form)
        ((= (length arguments) 1)
         `(characterp ,(car arguments)))
        (t (let* ((vars (loop for argument in arguments collect (gensym))))
             `(let ,(loop for var in vars
                          for arg in arguments
                          collect `(,var ,arg))
                (and ,@(loop for rest = (cdr vars) then (cdr rest)
                             while (consp rest)
                             for var1 = (car vars) then var2
                             for var2 = (car rest)
                             collect `(binary-char-not-greaterp ,var1 ,var2))))))))
 
