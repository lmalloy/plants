access(X) :- weapon_access(X), key_access(X), crime_access(X).

weapon_access(X) :- stay(X, thursday, lab).
weapon_access(X) :- stay(X, wednesday, csOffice).
weapon_access(X) :- stay(X, thursday, bookstore).
weapon_access(X) :- stay(X, wednesday, bookstore).

key_access(X) :- stay(X, monday, csOffice).
key_access(X) :- stay(X, tuesday, lab).

key_access(davis).

crime_access(X) :- stay(X, thursday, bookstore).
crime_access(X) :- stay(X, friday, bookstore).

stay(fu, monday, csOffice).
stay(fu, tuesday, csOffice).
stay(fu, wednesday, lab).
stay(fu, thursday, csOffice).
stay(fu, friday, bookstore).

stay(mcmillin, monday, lab).
stay(mcmillin, tuesday, lab).
stay(mcmillin, wednesday, lab).
stay(mcmillin, thursday, csOffice).
stay(mcmillin, friday, bookstore).

stay(das, monday, bookstore).
stay(das, tuesday, lab).
stay(das, wednesday, bookstore).
stay(das, thursday, bookstore).
stay(das, friday, bookstore).

stay(davis, monday, bookstore).
stay(davis, tuesday, lab).
stay(davis, wednesday, lab).
stay(davis, thursday, csOffice).
stay(davis, friday, bookstore).

stay(sabharwal, monday, bookstore).
stay(sabharwal, tuesday, bookstore).
stay(sabharwal, wednesday, csOffice).
stay(sabharwal, thursday, bookstore).
stay(sabharwal, friday, bookstore).

stay(markowsky, monday, bookstore).
stay(markowsky, tuesday, lab).
stay(markowsky, wednesday, lab).
stay(markowsky, thursday, bookstore).
stay(markowsky, friday, bookstore).

stay(price, monday, csOffice).
stay(price, tuesday, csOffice).
stay(price, wednesday, lab).
stay(price, thursday, csOffice).
stay(price, friday, bookstore).

stay(tauritz, monday, bookstore).
stay(tauritz, tuesday, csOffice).
stay(tauritz, wednesday, csOffice).
stay(tauritz, thursday, csOffice).
stay(tauritz, friday, bookstore).

motive(X, jealous):- victim(Y), jealous(X,Y).
motive(X, insane):-insane(X).
motive(X, poor):-poor(X).

jealous(X,Y):- friends_with(X,Z), friends_with(Y,Z).

victim(leopold).

insane(sabharwal).
insane(tauritz).

poor(davis).
poor(fu).
poor(morales).
poor(tauritz).

friends_with(X,Y):-friends(X,Y).
friends_with(X,Y):-friends(Y,X).

friends(leopold,price).
friends(price, mcmillin).
friends(leopold, fu).
friends(fu, markowsky).
friends(markowsky, das).
friends(das, tauritz).
friends(sabharwal, tauritz).
friends(sabharwal, mcmillin).

murderer(X, Y):- motive(X, Y), access(X).

