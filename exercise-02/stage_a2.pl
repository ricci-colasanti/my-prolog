% Exercise 2 — Facts about persons and ages

person(alice).
person(bob).
person(carol).
person(dan).
person(eve).
person(moby).

age(alice, 27).
age(bob,   45).
age(carol, 62).
age(dan,   29).
age(eve,   51).
age(moby,   3).
age(bob, 19).

adult(P) :- age(P,A) , A >= 18.

young_adult(P) :- age(P,A), A >= 18, A < 30. 
