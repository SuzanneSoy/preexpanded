#lang racket

(require (for-syntax preexpanded/syntax-case))

(define-syntax (define-a*-b stx)
  (syntax-case stx ()
    [(_ name [foo val] ...)
     #`(define-syntax (name stx2)
         #,(preexpanded-syntax-case/no-bind define-a*-b stx2
             [(_ #:a (~literal foo)) #'val]
             (foo val)
             ...
             [(_ #:b) #'2]))]))

(define-a*-b myab [a 10] [b 20] [c 30])
(myab #:a a)
(myab #:a b)
(myab #:a c)
;(myab #:a d)   ;; Invalid syntax, as expected
;(myab #:a)     ;; Invalid syntax, as expected
;(myab #:a a e) ;; Invalid syntax, as expected
(myab #:b)

#;(preexpanded-syntax-case/no-bind mymacro #'(mymacro #:a +)
    [(_ #:a (~literal +)) 1]
    [(_ #:b) 2])

#;(preexpanded-syntax-case/no-bind mymacro #'(mymacro #:b foo)
    [(_ #:a (~literal +)) 1]
    [(_ #:b (~datum foo)) 2])
