#lang racket

(provide preexpanded-syntax-case/no-bind)

(require (for-syntax preexpanded/and
                     racket/pretty
                     syntax/stx
                     syntax/parse
                     syntax/parse/experimental/template)
         syntax/stx)

(begin-for-syntax
  (define-syntax-class (pat part)
    #:attributes (test)
    (pattern (~literal _)
             #:with test #'#t)
    (pattern ()
             #:with test #`(null? #,part))
    (pattern ((~literal ~literal) identifier:id)
             #:when (syntax-pattern-variable?
                     (syntax-local-value #'identifier
                                         (λ _ #f)))
             #:with test #`(free-identifier=? #,part (quote-syntax identifier)))
    (pattern ((~literal ~literal) identifier:id)
             #:with test #`(free-identifier=? #,part (quote-syntax identifier)))
    (pattern ((~literal ~datum) identifier:id)
             #:with test #`(eq? (syntax-e #,part) 'identifier))
    (pattern k:keyword
             #:with test #`(eq? (syntax-e #,part) 'k))
    (pattern ((~var sub (pat #'car-part)) . (~var rest (pat #'cdr-part)))
             ;; TODO: optimize the #t case.
             #:with test (preexpanded-and
                          #`((stx-pair? #,part)
                             (let-values ([(car-part) (stx-car #,part)]
                                          [(cdr-part) (stx-cdr #,part)])
                               #,(preexpanded-and
                                  #'(sub.test rest.test))))))))


(begin-for-syntax
  (define-splicing-syntax-class (clause-maybe-dotted whole)
    (pattern (~seq [(~var pat (pat whole)) body]
                   (~optional (~seq (patvar ...)
                                    (~and ddd (~literal ...)))))
             #:with test #'pat.test
             ;#:with (patvar ...) #`#,(attribute pat.patvar)
             #:with expanded
             (if (attribute ddd)
                 #'(map (lambda (patvar ...)
                          (with-syntax ([patvar patvar] ...)
                            #'[test body]))
                        (syntax->list #'(patvar (... ...)))
                        ...)
                 #'(list #'[test body])))))

(define-syntax (preexpanded-syntax-case/no-bind stx)
  (syntax-parse stx
    [(_ name stx2 (~var clause (clause-maybe-dotted #'whole)) ...)
     ((λ (x)
        ;(pretty-write (syntax->datum x))
        x)
      #'#`(let-values ([(whole) stx2])
            (cond #,@clause.expanded
                  ...
                  [else (raise-syntax-error 'name "Invalid syntax" whole)])))]))