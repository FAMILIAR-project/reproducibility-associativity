;; Seeding *random-state*
(setf *random-state* (make-random-state t))

(defun associativity-test ()
  (let ((x (random most-positive-fixnum))
		(y (random most-positive-fixnum))
		(z (random most-positive-fixnum)))
	(= (+ x (+ y z)) (+ (+ x y) z))))

(defun proportion (iter)
  (/ (* 100 (count t (loop for i from 1 to iter collect (associativity-test)))) iter))

(format t "~A\%~%" (proportion 1000))