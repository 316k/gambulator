#!/usr/local/Gambit/bin/gsi
;#! /usr/bin/env gsi -:dR

;;; Fichier : tp2.scm

;;; Ce programme est une version incomplete du TP2.  Vous devez uniquement
;;; changer et ajouter du code dans la premi�re section.

;;;----------------------------------------------------------------------------

;;; Vous devez modifier cette section.  La fonction "traiter" doit
;;; �tre d�finie, et vous pouvez ajouter des d�finitions de fonction
;;; afin de bien d�composer le traitement � faire en petites
;;; fonctions.  Il faut vous limiter au sous-ensemble *fonctionnel* de
;;; Scheme dans votre codage (donc n'utilisez pas set!, set-car!,
;;; begin, etc).

;;; La fonction traiter re�oit en param�tre une liste de caract�res
;;; contenant la requ�te lue et le dictionnaire des variables sous
;;; forme d'une liste d'association.  La fonction retourne
;;; une paire contenant la liste de caract�res qui sera imprim�e comme
;;; r�sultat de l'expression entr�e et le nouveau dictionnaire.  Vos
;;; fonctions ne doivent pas faire d'affichage car c'est la fonction
;;; "repl" qui se charge de cela.

(define operators '(#\+ #\- #\* #\/))

; That --> https://stackoverflow.com/questions/5397144/how-do-i-compare-the-symbol-a-with-the-character-a
(define (char->symbol ch)
  (string->symbol (string ch)))

(define stack-eval-chelou
  (lambda (op a b)
    (eval `(,(char->symbol op) ,a ,b))))

(define traitement
  (lambda (expr dict stack)
    (if (null? expr)
      (cons (number->string (car stack)) dict)
      (cond
        ((member (car expr) operators)
          (traitement (cdr expr) dict (stack))))
        ((char-numeric? (car expr))
          (print "shat")))))

(define traiter
  (lambda (expr dict)
    (traitement expr dict '())
    (cons '(#\S #\h #\i #\t #\newline)
          dict)))

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
