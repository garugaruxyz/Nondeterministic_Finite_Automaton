;; nfa.lsp

;; (is-regexp RE) 

(defun is-regexp (RE)
  (cond ((atom RE) (check-op (list RE)))
        ((listp RE) (is-regexpL RE))
  ))

(defun is-regexpL (RE)
  (cond ((null RE) T)
    ((and (or (eql (car RE) 'star) (eql (car RE) 'plus))) 
     (and (= (list-length (cdr RE)) 1) (check-op (cdr RE)) (check-arg (cdr RE))))
    ((and (or (eql (car RE) 'seq) (eql (car RE) 'or)))   
     (and (> (list-length (cdr RE)) 1) (check-op (cdr RE)) (check-arg (cdr RE))))
    ((atom (car RE)) T)   
))

(defun check-arg (RE)
  (cond
     ((null RE) T)
    ((listp (car RE)) (and (is-regexpL (car RE)) (check-arg (cdr RE))))
    ((atom (car RE)) (check-arg (cdr RE)))
))


(defun check-op (RE)
  (if (equal (car RE) nil)
    T
  (and (not (eql (car RE) 'or)) 
      (not (eql (car RE) 'star))
      (not (eql (car RE) 'plus))
      (not (eql (car RE) 'seq))
      (check-op (cdr RE)))))



;;(nfa-regexp-comp RE) 

(defun nfa-regexp-comp (RE)
  (if (is-regexp RE)
    (let ((in (gensym)) (fin (gensym)))
      (list (list 'nfa-initial in) (list 'nfa-final fin)
      (cond ((atom RE) (list (list in RE fin)))
            ((or (eql (car RE) 'star) (eql (car RE) 'plus) 
              (eql (car RE) 'or) (eql (car RE) 'seq)) 
               (comp in RE fin))
            (T (list (list in RE fin))))))
   nil))


(defun comp (in RE fin)  
  (append  
    (cond 
      ((atom RE) (list (list in RE fin)))
      ((eql (car RE) 'star) (comp-star in (cdr RE) fin) )
      ((eql (car RE) 'plus) (comp-plus in (cdr RE) fin) )
      ((eql (car RE) 'or)   (comp-or in (cdr RE) fin) )
      ((eql (car RE) 'seq) (comp-seq in (cdr RE) fin) )
      (T (list (list in RE fin)))
  )
))

(defun comp-seq (in RE fin)
  (if (not (null (cdr RE)))
    (let ((state (gensym)) (state2 (gensym)))
    (append
      (cond 
        ((atom (car RE))  (list (list in (car RE) state)))
        ((listp (car RE))  (comp in (car RE ) state))
      )
      (list (list state 'epsilon state2))
      (comp-seq state2 (cdr RE) fin)  
    ))
    (comp in (car RE) fin)
))


(defun comp-plus (in RE fin)
    (let ((state (gensym)) (state2 (gensym)))
      (append
        (cond 
          ((atom (car RE))  (list (list state (car RE) state2)))
          ((listp (car RE))  (comp state (car RE ) state2)))
        (list (list in 'epsilon state))
        (list (list state2 'epsilon state))
        (list (list state2 'epsilon fin))
      ))
)

(defun comp-star (in RE fin)
  (let ((state (gensym)) (state2 (gensym)))
    (append
      (cond 
        ((atom (car RE))  (list (list state (car RE) state2)))
        ((listp (car RE))  (comp state (car RE ) state2)))
      (list (list in 'epsilon fin))
      (list (list in 'epsilon state))
      (list (list state2 'epsilon state))
      (list (list state2 'epsilon fin))
    ))
)


(defun comp-or (in RE fin)
  (if (not (null RE))
      (let ((state (gensym)) (state2 (gensym)))
        (append
          (list (list in 'epsilon state))
          (cond 
            ((atom (car RE)) (list (list state (car RE) state2)))
            ((listp (car RE)) (comp state (car RE) state2)))
          (list (list state2 'epsilon fin))
          (comp-or in (cdr RE) fin) 
        )
      )
))

;; (nfa-test FA Input)

(defun valid (NFA)
  (if (and (listp NFA) (not (null NFA)) (check-nfa NFA)) 
   T
  (error "~S is not a Finite State Automata." NFA))
)

(defun check-nfa (NFA)
  (and
    (listp (first NFA))
    (equal (first (first NFA)) 'nfa-initial)
    (listp (second NFA))
    (equal (first (second NFA)) 'nfa-final)
    (listp (third NFA))
    (check-nfa-delta (third NFA))
  )
)

(defun check-nfa-delta (NFA)
  (cond 
    ((null NFA) T)
    ((and (listp (car NFA)) (= (length (car NFA)) 3)) 
      (check-nfa-delta (cdr NFA)))
    (T nil)
  )
)


(defun nfa-test (NFA input)
  (if (and (listp input) (valid NFA))
    (let 
      ((IN (first (last (first NFA)))) 
      (FIN (first (last (second NFA)))) 
      (DELTA (first (last NFA))))
      (nfa-test-control IN DELTA input FIN)
    ) nil
  )
)

 
(defun nfa-test-control (IN DELTA input FIN)
  (let ((STATE (nfa-test-state IN DELTA)))
    (cond 
      ((or (nfa-test-prova IN DELTA input FIN (car STATE)) 
      (nfa-test-control1 IN DELTA input FIN (cdr STATE))) T)
    )
  )
)


(defun nfa-test-prova (IN DELTA input FIN STATE)
  (cond 
    ((and (equal IN FIN) (null input)) T)
    ((equal (second STATE) (car input)) 
      (nfa-test-control (first (last STATE)) DELTA (cdr input) FIN)) 
    ((equal (second STATE) 'epsilon) 
      (nfa-test-control (first (last STATE)) DELTA input FIN))  
  )
)


(defun nfa-test-control1 (IN DELTA input FIN STATE)
  (cond 
    ((null STATE)  nil) 
    ((or (nfa-test-prova IN DELTA input FIN (car STATE)) 
      (nfa-test-control1 IN DELTA input FIN (cdr STATE))) T)  
  )
)


(defun nfa-test-state (IN DELTA)
  (if (not (null DELTA))
  (append  
    (cond 
      ((null DELTA))
      ((equal IN (first (first DELTA))) (list (first DELTA)))
    )
  (nfa-test-state IN (cdr DELTA))))
)


  
