Good. Stage A symbolic layer is now verified end-to-end — that's the foundation everything else sits on. Before Exercise 5, here's the consolidated Stage-A code so far, so you can drop it into a fresh file and build on it. I'm giving you this because you asked, not as a shortcut.

```prolog
% ============================================================
% Stage A — Symbolic layer (household mobility microsimulation)
% Verified: mobility_score/2 matches hand computation.
% ============================================================

% --- Facts: persons and attributes ---
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

% --- Facts: households and tenure ---
tenure(h_alice, rented).
tenure(h_bob,   owned).
tenure(h_carol, rented).
tenure(h_dan,   rented).
tenure(h_eve,   owned).

% --- Facts: person -> household (one-to-one for the toy) ---
lives_in(alice, h_alice).
lives_in(bob,   h_bob).
lives_in(carol, h_carol).
lives_in(dan,   h_dan).
lives_in(eve,   h_eve).

% --- Component rules (hand-specified weights) ---
age_component(A, 3) :- A < 30, !.
age_component(A, 1) :- A >= 30, A < 50, !.
age_component(A, 0) :- A >= 50.

income_component(low,    2).
income_component(medium, 1).
income_component(high,   0).

tenure_component(rented, 2).
tenure_component(owned,  0).

% --- Main rule ---
mobility_score(P, Score) :-
    age(P, A),
    income(P, I),
    lives_in(P, H),
    tenure(H, T),
    age_component(A, C1),
    income_component(I, C2),
    tenure_component(T, C3),
    Score is C1 + C2 + C3.
```

A couple of things worth noticing before we move on, because they matter for Exercise 5:

- `mobility_score/2` is **relational**, not a function. It will happily enumerate all persons on backtracking. That property is what makes Exercise 5 possible.
- The `!` cuts in `age_component/2` make those clauses deterministic — one answer per age. That matters when you start collecting results with `findall/3`, because a stray choicepoint can produce duplicate rows.
- The rule currently **fails silently** for anyone missing a fact. That's the seed of the Critic's job later — right now the KB is complete, so it doesn't bite. Hold that thought.

---

## Exercise 5 — `findall/3` and `most_likely_to_move/2`

### 1. What

`findall/3` is Prolog's way of saying: "run this goal, and collect *every* solution it produces into a list — don't stop at the first one, don't leave a choicepoint hanging."

Signature: `findall(Template, Goal, List)`

- `Template` — what you want captured for each solution (e.g. `P-S`).
- `Goal` — the goal to run (e.g. `mobility_score(P, S)`).
- `List` — the output list. Must be unbound on call; `findall/3` binds it.

`findall/3` is **deterministic**: it always succeeds exactly once, even if `Goal` has zero solutions (then `List = []`). Contrast with a bare `mobility_score(P, S)` query, which leaves choicepoints and, on backtracking, hands you one answer at a time.

The central question of the toy — "which person is most likely to move?" — is really: *compute all scores, pick the maximum*. That's two steps, and `findall/3` is step one.

### 2. Why

This is where the reasoning engine starts to **aggregate**. Up to now you've had single queries. Real inference needs to collect candidate answers across the whole KB, then rank or filter them.

For the architecture: this is also the shape of gap detection later. When the Critic wants to know "what is the current best hypothesis about who moves?", it will collect all scored candidates and reason over the set. `findall/3` is the primitive that turns "the KB has answers" into "here is a list of answers the reasoning engine can inspect."

There's also a Prolog-specific trap here worth meeting head-on: `findall/3` is one of the standard **all-solutions predicates**, and its siblings (`bagof/3`, `setof/3`) behave subtly differently around free variables and failure. We'll only use `findall/3` today — but know that the family exists, and that choosing the wrong sibling is a classic source of silent bugs.

### 3. Do

Two tasks in one file. Type them yourself.

**Task 5a — get the list.**

Write a rule `all_scores/1` that takes an unbound `Scores` and binds it to the list of `P-S` pairs for every person. Something like:

```
all_scores(Scores) :- findall(..., ..., Scores).
```

Query it and look at what comes back.

**Task 5b — pick the winner.**

Write a rule `most_likely_to_move(P, S)` that:
- gets the list of `P-S` pairs,
- finds the maximum `S` in that list,
- returns the person `P` associated with that maximum score.

You have not yet been taught list predicates in this course. That's deliberate. I want you to reach for what you *do* have first — and I'll teach you the list machinery properly in a moment if you want it. Two viable approaches:

- **Without list library predicates:** write a small helper that walks the list recursively. This is the "eat your greens" route — it forces you to see lists as cons cells and to practise recursion, which is the Prolog mental model you're rebuilding.
- **With `library(lists)`:** SWI ships `max_member/2` and friends. Convenient, but skips the learning. Your call — but if you take this route, I'll ask you to also write the recursive version afterwards, because the recursion is the point.

Don't paste either approach blind. Decide, then write it, then query.

### 4. Discuss

After you run it, notice:

- The order of pairs in the `findall/3` result. Is it the order you wrote the facts in? Why? (Hint: it's the order of solutions the goal produces on backtracking.)
- What happens if you call `all_scores(S)` with `S` already bound to something? Try `all_scores([alice-7])`. What does Prolog do? This is the relational-vs-functional distinction again — `findall/3` *binds*, it doesn't *check*.
- For `most_likely_to_move/2`: what happens if two people tie on the maximum score? What did your rule do? Is that the behaviour you want? (This is the tie-breaking lesson from earlier — it'll come back.)
- Whether your rule left any choicepoints behind. Query with `most_likely_to_move(P, S).` and press `;`. If Prolog asks for more, you've got a choicepoint you didn't intend.

### 5. Report back

Tell me:

- What `all_scores(S)` returned, verbatim.
- What `most_likely_to_move(P, S)` returned, and whether pressing `;` produced more answers.
- Which route you took (recursive helper or library predicate) and why.
- Anything that surprised you, and anything that broke.

Then I'll respond, and *only then* will we move toward the next exercise. No peeking ahead.

One last thing, because it's the pitfall most relevant here: if you find yourself thinking "I need a variable to hold the running maximum and update it in a loop," stop. That's the mutable-variable ghost. Prolog has no assignment — you'll hold the maximum in a *recursive call's accumulator*, passed as an argument. If that sentence doesn't yet make sense, that's fine — it's the lesson.
