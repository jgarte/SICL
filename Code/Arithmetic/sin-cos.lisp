(cl:in-package #:sicl-arithmetic)

;;; This code is highly experimental, and I am not sure that it will
;;; be any better than other techniques.  Also, some of the
;;; computations made here are much better done on the binary
;;; representation of the floating-point numbers.

;;; We use the SIN and COS functions to fill the tables, but that is
;;; obviously wrong.  Some other methods must be used.

(defparameter *significant-bits* 7)

;;; This is the number of fractions that a radian is divided into.
(defparameter *radian-fractions-count*
  (ash 1 *significant-bits*))

;;; This is the size of the table that we need in order to represent
;;; fractions of radians from 0 below pi/4.
(defparameter *table-length*
  (truncate (* *radian-fractions-count* (/ pi 4d0))))

;;; This function computes a base angle from ANGLE.  The base angle is
;;; the largest value that is smaller than or equal to ANGLE and that
;;; can be expressed as (/ N *RADIAN-FRACTION-COUNT*) where N is an
;;; integer.  Normally, this function would be computed by
;;; manipulating the bits of the floating-point representation of
;;; ANGLE.  The angle is assumed to be less than or equal to pi/4.
(defun base-angle (angle)
  (/ (float (floor (* angle *radian-fractions-count*)) 1d0)
     (float *radian-fractions-count* 1d0)))

;;; This table contains values for (SIN X) where X is a base angle
;;; between 0 and pi/4.
(defparameter *sin-table*
  (let ((result (make-array *table-length* :element-type 'double-float)))
    (loop for i from 0 below *table-length*
          for angle = (float (/ i *radian-fractions-count*) 1d0)
          do (setf (aref result i)
                   (sin angle)))
    result))

;;; This table contains values for (COS X) where X is a base angle
;;; between 0 and pi/4.
(defparameter *cos-table*
  (let ((result (make-array *table-length* :element-type 'double-float)))
    (loop for i from 0 below *table-length*
          for angle = (float (/ i *radian-fractions-count*) 1d0)
          do (setf (aref result i)
                   (cos angle)))
    result))