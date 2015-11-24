#!/usr/local/Gambit/bin/gsi
;#! /usr/bin/env gsi -:dR

;;; Fichier : tp2.scm

;;; Ce programme est une version incomplete du TP2.  Vous devez uniquement
;;; changer et ajouter du code dans la première section.

;;;----------------------------------------------------------------------------

;;; Vous devez modifier cette section.  La fonction "traiter" doit
;;; être définie, et vous pouvez ajouter des définitions de fonction
;;; afin de bien décomposer le traitement à faire en petites
;;; fonctions.  Il faut vous limiter au sous-ensemble *fonctionnel* de
;;; Scheme dans votre codage (donc n'utilisez pas set!, set-car!,
;;; begin, etc).

;;; La fonction traiter reçoit en paramètre une liste de caractères
;;; contenant la requête lue et le dictionnaire des variables sous
;;; forme d'une liste d'association.  La fonction retourne
;;; une paire contenant la liste de caractères qui sera imprimée comme
;;; résultat de l'expression entrée et le nouveau dictionnaire.  Vos
;;; fonctions ne doivent pas faire d'affichage car c'est la fonction
;;; "repl" qui se charge de cela.


(define & (lambda (a b) (and a b)))

(define operators
  '((#\+ #\- #\* #\/ #\> #\< #\&) 2))

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

(define boolean->number
  (lambda (x) (if x 1 0)))

; Dépile 2 arguments de stack et empile le résultat de op dessus
(define stack-eval-chelou
  (lambda (op stack)
    (cons
      (let ((out ((eval (char->symbol op)) (car stack) (cadr stack))))
        (if (boolean? out)
          (boolean->number out)
          out))
      (cddr stack))))

(define post-eval
  (lambda (expr dict stack building-number?)
    (if (null? expr)
      (cons
        (if (null? stack)
          (string->list "Rien à faire\n")
          (append (string->list (number->string (car stack))) '(#\newline))) dict)
      (let ((stack-top (car-or-false stack)) (symbol (car expr)) (rest (cdr expr)))
        (cond
          ((member symbol (car operators)) ; opérateurs
            (post-eval rest dict (stack-eval-chelou symbol stack) #f))
          ((char-numeric? symbol) ; entrée de nombres
            (if building-number?
              (post-eval rest dict
                  (cons (+ (char->number symbol) (* 10 stack-top)) (cdr stack)) #t)
              (post-eval rest dict
                  (cons (char->number symbol) stack) #t)))
          (else ; espaces et caractères inconnus
            (post-eval rest dict stack #f)))))))

(define traiter
  (lambda (expr dict)
    (post-eval expr dict '() #f)))
;    (cons (string->list "123") dict)))

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
    (traiter (string->list ligne)  dict)))

(define main
  (lambda ()
    (repl '()))) ;; dictionnaire initial est vide

;;;----------------------------------------------------------------------------
