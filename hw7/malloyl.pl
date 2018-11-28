% Knowledge Base & Relations

animal(X) :- mammal(X).
animal(X) :- bird(X).
animal(X) :- fish(X).        

covering(X, fur) :- mammal(X).
covering(X, feathers) :- bird(X).    
covering(X, scales) :- fish(X). 

legs(X, 2) :- primate(X).
legs(X, 4) :- mammal(X).
legs(X, 2) :- bird(X).
legs(X, 0) :- fish(X).   
 

mammal(X) :- cat(X).    
mammal(X) :- dog(X).
mammal(X) :- primate(X). 

sound(X, bark) :- dog(X).
sound(X, purr) :- cat(X).  

cat(sylvester).
cat(felix).
dog(spike).
dog(fido).
primate(george).
primate(kingkong).
bird(tweety).

bird(X) :- hawk(X).
hawk(tony).
fish(nemo).











% if mammal then whatever passed to it is covering its furx used as what is passed to
%    felix x 

