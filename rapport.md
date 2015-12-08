# Gambulator

Par Guillaume Riou et Nicolas Hurtubise

## Introduction

**Gambulator** fonctionne sensiblement de la même façon que **Stackulator II**™, à plusieurs fonctionnalités près.

À la différence de notre précédent TP, la pile n'est pas gardée d'une entrée utilisateur à l'autre. Par exemple, taper :

    ? 10 10 +
    ? 2 *

Résulte en une erreur plutôt qu'en `40` (il n'y a pas assez d'arguments sur la pile pour la multiplication à la deuxième ligne).

Nous avons cependant pu ajouter quelques opérateurs supplémentaires, tels que le & et le | pour le "et" et le "ou".
Nous avons aussi réimplanté la fonctionnalité de définition et d'appel de procédures qui faisaient partie de **Stackulator II**™. Ainsi 
il est possible de définir une fonction et de l'appeler de cette manière :

    ? :A =a a *;
    ? 5 A
    25

Dans cet extrait, la fonction 'A' sert à mettre un nombre au carré.

## Implantation de Gambulator

*a)* L'analyse syntaxique d'une expression dans notre code se fait de la manière suivante : l'utilisateur entre une chaîne de caractère contenant des commandes. Gambulator traite les caractères un à la fois et fait différents traitements selon le type de caractère trouvé. La fonction `process-input` se charge de consomer l'entrée de façon à retourner le résultat à afficher et à faire les affectations de variables nécessaires. `process-input` utilise la syntaxe `cond` de gambit pour détecter quel traitement particulier doit être effectué sur l'entrée, la pile, le dictionnaire et si des erreurs ont lieu lors de l'analyse.

Si le caractère rencontré est une chaîne contenant des caractères numériques, on entre dans une procédure de construction de nombres et évalue le reste de la chaîne caractère par caractère tant que le caractère rencontré est encore un nombre. À la fin de cette procédure, le nombre est ajouté au dessus de la pile et le traitement de la chaîne continue.

*b)* Si le caractère est une fonction reconnue par Gambulator telle que l'addition, la soustraction, etc ... Gambulator évalue cette fonction en regardant dans une liste d'associations `((#\caractère procédure) ...)` avec les deux premiers nombres du stack en paramètres.

Les opérateurs supportés sont :

    + - * < > & |

Qui sont tous des opérateurs requierant 2 opérandes.

Contrairement à la majorité des opérateurs qui sont des procédures standards de scheme inclus dans gambit, `&` et `|` correspondent respectivement aux macros `and` et `or` et doivent être adaptées pour être appelés de la même façon que les autres procédures :

    (define & (lambda (a b) (and a b)))
    (define my-or (lambda (a b) (or a b)))

Il est intéressant de noter que, contrairement à notre implémentation C, la tour des nombres supportés par Gambit nous permet d'utiliser sans encombres des nombres à grandeur arbitraire avec toutes les opérations mathématiques supportées.

*c)* Si le caractère lu est `=` et qu'il est suivi d'une lettre minuscule, on procède à une affectation de variable. Les variables sont "stockées" dans une liste d'association nommée `dict`. Des fonctions pour insérer des nouvelles associations dans une *alist* ont été définies : `update-assoc`, `add-assoc`, `remove-assoc` et `lookup` (inspirée des diapositives du cours). Bien entendu, si l'expression entrée comporte une erreur de sytaxe, le dictionnaire original n'est pas modifié lors de la prochaine évaluation.

*d)* La fonction `process-input` retourne un `(cons [liste de caractères à afficher] [dictionnaire à utiliser lors de la prochaine évaluation])`. La fonction `traiter` se charge alors de passer ce résultat à `repl` pour continuer à lire l'entrée.

*e)* Les erreurs sont traitées par `process-input` à l'aide d'une continuation passée en paramètre. Le fait d'utiliser une continuation permet de stopper la consommation de l'entrée par `process-input` lorsqu'une erreur survient. La continuation étant définie dans le corps de la fonction `traiter`, elle a dans son environnement la variable `dict` dans l'état où elle était avant que l'erreur se produise. Quand la fonction `process-input` se fait interrompre par une erreur, elle renvoie un `(cons [liste de caractères correspondants au message d'erreur] [ancient dictionnaire])`. La liste de caractères est alors affichée par la fonction repl.

*f)* Si le caractère lu est `:` et qu'il est suivi d'une lettre majuscule, on procède à une définition de procédure. Une procédure étant délimitée par `:X ... ;`, on s'assure de valider qu'un `;` est présent pour effectuer la définition. De plus, pour simplifier la définition de procédures, il est interdit de définir des procédures à l'intérieur d'autres définitions de procédures. Ces erreurs sont reconnues par Gambulator et sont traitées par une continuation de la même façon que les autres erreurs d'entrées.

Il est à noter que, puisque les procédures sont remplacées textuellement dans la liste d'entrée lorsqu'elles sont appellées, les appels récursifs causent des boucles infinies.

Le stockage des procédures se fait à même le dictionnaire de variables.

*Note : La longueur des expressions entrées peut être arbitraire, gambit nous permettant d'utiliser simplement des listes plutôt que des tableaux de taille fixe.*

## Gambulator (Gambit) vs. Stackulator (C)

Gambit propose trois avantages plutôt importants vis à vis C :

1. La gestion de mémoire est automatisée, plutôt que gérée manuellement
2. Les nombres à précision infinie et les opérations arithmétiques reliées sont directement supportés par le langage
3. La structure de base du Scheme étant la liste, utiliser une pile est nativement supporté

Le nombre de lignes de code nécessaires pour arriver à un résultat sensiblement similaire en est donc considérablement réduit :


  Langage utilisé     Nombre de lignes de code
-----------------     ------------------------
     C                 1581
   Gambit              155

: Comparaison du nombre de lignes de code utilisées pour réaliser sensiblement la même chose en Gambit vs en C

La première implémentation en C comportait quelques fonctionnalités supplémentaires (ex.: les boucles, des opérateurs supplémentaires, des fonctions d'affichage), mais restait majoritairement composée de code servant à implémenter les structures de base du programme : ~600 lignes pour les nombres à précision infinie et ~100 lignes pour la gestion du stack.

Gambulator, en revanche, n'a pratiquement pas de code relié à de la gestion de structures (si ce n'est que les 21 lignes consacrées aux *alist*). Le temps passé à écrire du code était donc du temps passé sur la logique d'implantation de la calculatrice au lieu de servir à bâtir des échaffaudages pour soutenir cette logique.

Pour ce qui est de la gestion de mémoire (facilement 25% du temps passé sur le projet en C), le problème était inexistant avec Gambit. Le temps passé sur le programme donc été considérablement plus bas avec Gambit.

Vu le support natif des grands entiers de Gambit, une bonne partie des fonctionnalités du programme ont été triviales à coder par rapport à leur pendants implantés en c. Par contre, pour ce qui est des variables, l'implantation en c s'est faite par un simple tableau de pointeurs alors qu'en Scheme il a fallu coder quelques fonctions relatives aux alist. Ces listes particulières sont la seule partie du projet ayant été plus "complexe" à programmer, tout le reste étant très facile à faire en Scheme.

Le style fonctionnel a permis une grande élégance au niveau du traitement de l'entrée utilisateur. En effet, notre fonction traitant l'entrée est récursive et consomme toute la chaîne en retournant le résultat, sans modifier des données globales. Cela qui assure la cohérence de nos données même en cas d'erreur dans l'entrée de l'utilisateur : en effet, il aurait été beaucoup plus complexe de rétablir le dictionnaire de variables en cas d'erreur dans un style impératif. Dans notre programme, une simple fermeture nous a permis de conserver l'état du dictionnaire pour le rétablir en cas d'erreur.

Plusieurs fonctions utilisent la récursion terminale : `remove-assoc`, `number/rest`, `procedure/rest` et `process-input`. La récursion terminale est utile lorsqu'on veut parcourir efficacement les éléments d'une liste, ce qui s'est avéré être souvent pratique durant notre projet.

Nous avons utilisé des continuations pour le traitement d'erreurs. Les continuations nous ont permis d'arrêter le flot d'exécution normal de notre procédure de traitement d'entrée de manière élégante et purement fonctionnelle.



