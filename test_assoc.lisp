;; Seeding *random-state*
(setf *random-state* (make-random-state t))

; https://stackoverflow.com/questions/11006798/how-can-i-obtain-a-negative-random-integer-in-common-lisp
(defun my-random (n)
    (- (random (1+ (* 2 n))) n))

; classical implementation
;(defun my-random (n)
;    (random n))

(defun associativity-test ()
  (let ((x (my-random most-positive-fixnum))
		(y (my-random most-positive-fixnum))
		(z (my-random most-positive-fixnum)))
	(= (+ x (+ y z)) (+ (+ x y) z))))

(defun proportion (iter)
  (/ (* 100 (count t (loop for i from 1 to iter collect (associativity-test)))) iter))

(format t "~A\%~%" (proportion 100000))