#lang racket

(provide preexpanded-and)

(require syntax/parse
         (for-template racket/base))

(define (preexpanded-and stx)
  (syntax-parse stx
    [(clause)
     #'clause]
    [(#t . rest)
     (preexpanded-and #`rest)]
    [(clause . rest)
     #`(if clause
           #,(preexpanded-and #`rest)
           #f)]))