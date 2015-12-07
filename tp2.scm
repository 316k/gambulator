#!/usr/local/Gambit/bin/gsi
;#! /usr/bin/env gsi -:dR

;;; Fichier : tp2.scm

(define & (lambda (a b) (and a b)))
(define my-or (lambda (a b) (or a b)))

(define operators `((#\+ . ,+) (#\- . ,-) (#\* . ,*) (#\/ . ,/) (#\> . ,>) (#\< . ,<) (#\& . ,&) (#\| . ,my-or)))

(define car-or-false
  (lambda (list)
    (if (null? list)
        #f
        (car list))))

; That --> https://stackoverflow.com/questions/5397144/how-do-i-compare-the-symbol-a-with-the-character-a
(define (char->symbol ch)
  (string->symbol (string ch)))

(define (char->number ch)
  (- (char->integer ch) (char->integer #\0)))

(define (boolean->number x) (if x 1 0))

; Dépile 2 arguments de stack et empile le résultat de op dessus
(define stack-eval
  (lambda (op stack)
    (cons
      (let ((out ((lookup op operators) (cadr stack) (car stack))))
        (if (boolean? out)
          (boolean->number out)
          out))
      (cddr stack))))

; Helpers pour les tables d'association
(define (lookup key env)
  (let ((pair (assoc key env)))
    (and pair (cdr pair))))

(define remove-assoc
  (lambda args
    (if (= (length args) 2) ; 2 arguments : key env
      (remove-assoc (car args) (cadr args) '())
      (let ((key (car args)) (old-env (cadr args)) (new-env (caddr args)))
        (if (null? old-env)
          new-env
          (if (eq? (caar old-env) key)
            (remove-assoc key (cdr old-env) new-env) ; skip le symbole à enlever
            (remove-assoc key (cdr old-env) (append new-env (list (car old-env))))))))))

'((a 1) (c 3))

(define (add-assoc key val env)
  (cons (cons key val) env))

(define (update-assoc key val env)
  (if (assoc key env)
      (add-assoc key val (remove-assoc key env))
      (add-assoc key val env)))

; (number/rest '(#\1 #\2 #\3 #\= #\a)) => (123 #\= #\a)
(define (number/rest expr)
  (let enumerate-shitz ((expr expr) (built '()))
    (if (and (not (null? expr)) (char-numeric? (car expr)))
      (enumerate-shitz (cdr expr) (cons (car expr) built))
      (cons (string->number (list->string (reverse built))) expr))))

(define semicolon #\;)

(define (procedure/rest expr)
  (let find-semicolon ((expr expr) (built '()))
    (cond
     ((or (null? expr) (char=? (car expr) #\:))
      #f)
     ((not (char=? (car expr) semicolon))
      (find-semicolon (cdr expr) (cons (car expr) built)))
     (else
      (cons (reverse built) (cdr expr))))))

(define post-eval
  (lambda (expr dict stack exception-handler)
    (if (null? expr)
      (cons
        (if (null? stack)
          (string->list "Rien à faire\n")
          (append (string->list (number->string (car stack))) '(#\newline)))
        dict)
      (let ((stack-top (car-or-false stack))
            (symbol (car expr))
            (rest (cdr expr)))
        (cond
         ((and (lookup symbol operators)
               (>= (length stack) 2))
          (post-eval rest dict (stack-eval symbol stack) exception-handler))
         ((char-numeric? symbol) ; entrée de nombres
          (let ((n/r (number/rest expr)))
            (post-eval (cdr n/r) dict (cons (car n/r) stack) exception-handler)))
         ((and stack-top
               (char=? symbol #\=)
               (not (null? rest))
               (char-lower-case? (car rest))) ; sauvegarde de variables
          (post-eval (cdr rest) (update-assoc (cadr expr) stack-top dict) stack exception-handler))
         ((and (eq? symbol #\:)
               (not (null? rest))
               (not (null? (cdr rest)))
               (char-upper-case? (cadr expr)))
          (let ((p/r (procedure/rest (cdr rest))))
            (if p/r
                (post-eval (cdr p/r) (update-assoc (cadr expr) (car p/r) dict) stack exception-handler)
                (exception-handler "Mauvaise définition de procédure\n"))))
         ((lookup symbol dict) ; push de variables
          (if (char-upper-case? symbol)
              (post-eval (append (lookup symbol dict) rest) dict stack exception-handler)
              (post-eval rest dict (cons (lookup symbol dict) stack) exception-handler)))
         ((char=? symbol #\space) ; espaces
          (post-eval rest dict stack exception-handler))
          ; Erreurs
         ((lookup symbol operators)
          (exception-handler "Pas assez d'arguments sur la pile \n"))
         ((and (char-lower-case? symbol) (char-alphabetic? symbol))
          (exception-handler (string-append (string symbol) " n'a pas de valeur\n")))
         ((and (char-upper-case? symbol) (char-alphabetic? symbol))
          (exception-handler (string-append "La procédure " (string symbol) " n'est pas une définie\n")))
         ((char=? symbol #\:)
          (exception-handler "Impossible d'effectuer l'assignation de procédure demandée\n"))
         ((char=? symbol #\=)
          (exception-handler "Impossible d'effectuer l'assignation demandée\n"))
         (else
          (exception-handler "Caractère inconnu `" (string symbol) "`\n")))))))

(define (traiter expr dict)
  (post-eval expr dict '()
    (lambda (e)
      (cons (string->list (string-append "Erreur d'entrée : " e)) dict))))

;;;----------------------------------------------------------------------------

;;; Ne pas modifier cette section.

(define repl
  (lambda (dict)
    (print "? ")
    (let ((ligne (read-line)))
      (if (string? ligne)
          (let ((r (traiter-ligne ligne dict)))
            (for-each write-char (car r))
            (repl (cdr r)))))))

(define traiter-ligne
  (lambda (ligne dict)
    (traiter (string->list ligne) dict)))

(define main
  (lambda ()
    (repl '()))) ;; dictionnaire initial est vide

;;;----------------------------------------------------------------------------
