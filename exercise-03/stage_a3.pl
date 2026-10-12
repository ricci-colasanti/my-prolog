% Exercise 3 — Facts about ages

age(alice, 27).
age(bob,   45).
age(carol, 62).
age(dan,   29).
age(eve,   51).



age_component(A,3)  :- A < 30, !.
age_component(A,1)	:- A >= 30, A < 50, !.
age_component(A,0)	:- A>=50,!.
