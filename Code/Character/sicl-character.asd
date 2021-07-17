(cl:in-package #:asdf-user)

(defsystem #:sicl-character
  :depends-on (#:cl-unicode
               #:cleavir-code-utilities)
  :serial t
  :components
  ((:file "packages")
   (:file "characterp-defun")
   (:file "upper-case-p-defun")
   (:file "lower-case-p-defun")
   (:file "char-upcase-defun")
   (:file "char-downcase-defun")
   (:file "binary-char-equal-1-defun")
   (:file "char-equal-1-defun")
   (:file "char-equal-1-define-compiler-macro")
   (:file "binary-char-lessp-1-defun")
   (:file "char-lessp-1-defun")
   (:file "char-lessp-1-define-compiler-macro")
   (:file "binary-char-not-greaterp-1-defun")
   (:file "char-not-greaterp-1-defun")
   (:file "char-not-greaterp-1-define-compiler-macro")
   (:file "binary-char-greaterp-1-defun")
   (:file "char-greaterp-1-defun")
   (:file "char-greaterp-1-define-compiler-macro")
   (:file "binary-char-not-lessp-1-defun")
   (:file "char-not-lessp-1-defun")
   (:file "char-not-lessp-1-define-compiler-macro")
   (:file "binary-char-equal-2-defun")
   (:file "char-equal-2-defun")
   (:file "char-equal-2-define-compiler-macro")
   (:file "binary-char-lessp-2-defun")
   (:file "char-lessp-2-defun")
   (:file "char-lessp-2-define-compiler-macro")
   (:file "binary-char-not-greaterp-2-defun")
   (:file "char-not-greaterp-2-defun")
   (:file "char-not-greaterp-2-define-compiler-macro")
   (:file "binary-char-greaterp-2-defun")
   (:file "char-greaterp-2-defun")
   (:file "char-greaterp-2-define-compiler-macro")
   (:file "binary-char-not-lessp-2-defun")
   (:file "char-not-lessp-2-defun")
   (:file "char-not-lessp-2-define-compiler-macro")
   (:file "char-code-defun")
   (:file "code-char-defun")))
