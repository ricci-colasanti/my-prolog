% Exercise 4 — Facts

person(alice). person(bob). person(carol). person(dan). person(eve).

household(h_alice). household(h_bob). household(h_carol).
household(h_dan).   household(h_eve).

lives_in(alice, h_alice).
lives_in(bob,   h_bob).
lives_in(carol, h_carol).
lives_in(dan,   h_dan).
lives_in(eve,   h_eve).

age(alice, 27).
age(bob,   45).
age(carol, 62).
age(dan,   29).
age(eve,   51).

income(alice, low).
income(bob,   high).
income(carol, medium).
income(dan,   medium).
income(eve,   high).

tenure(h_alice, rented).
tenure(h_bob,   owned).
tenure(h_carol, rented).
tenure(h_dan,   rented).
tenure(h_eve,   owned).


% Exercise 4 — Score components

age_component(A, 3) :- A < 30, !.
age_component(A, 1) :- A >= 30, A < 50, !.
age_component(A, 0) :- A >= 50.

income_component(low,    2).
income_component(medium, 1).
income_component(high,   0).

tenure_component(rented, 2).
tenure_component(owned,  0).


% Exercise 4 — The score

mobility_score(P, Score) :-
    age(P, A),
    income(P, I),
    lives_in(P, H),
    tenure(H, T),
    age_component(A, C1),
    income_component(I, C2),
    tenure_component(T, C3),
    Score is C1 + C2 + C3.
