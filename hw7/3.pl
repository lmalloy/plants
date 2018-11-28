access(X) :- weapon_access(X), key_access(X), crime_access(X)).

weapon_access(X) :- stay(X, Thursday, lab).

weapon_access(X) :- stay(X, Wednesday, cs_office).

weapon_access(X) :- stay(X, Thursday, bookstore).

weapon_access(X) :- stay(X, Wednesday, bookstore).

key_access(X) :- stay(X, Monday, cs_office).

key_access(X) :- stay(X, Tuesday, lab).

key_access(david).

crime_access(X) :- stay(X, Thursday, bookstore).

crime_access(X) :- stay(X, Friday, bookstore).




