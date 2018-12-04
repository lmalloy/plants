#!/usr/bin/swipl

:- set_prolog_flag(verbose, silent).

:- initialization main.

main :-
  current_prolog_flag(argv, Argv),
  myReverse(Argv, X),
  print(X),
  halt.
main :-
  halt(1).


myReverse([], []).
myReverse([H | T], X) :- myReverse(T, Y), append(Y, [H], X).


