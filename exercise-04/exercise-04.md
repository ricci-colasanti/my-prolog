## Exercise 4: The Full Score

### 1. What (the concept)

The toy's central question is: **"Which person is most likely to move in the next year?"**

To answer that, the reasoning engine needs a *number* per person — a score — that says "how likely is this person to move?" Higher number = more likely. Once every person has a number, the answer to the central question is just "who has the highest number?"

`mobility_score/2` is the rule that computes that number. It looks up three facts about a person, translates each into a numeric contribution via a small component predicate, sums the three contributions, and returns the total.

The three contributions are hand-specified:

- **Age** — young people move more. `< 30 → +3`, `30–49 → +1`, `>= 50 → +0`.
- **Income** — lower income moves more. `low → +2`, `medium → +1`, `high → +0`.
- **Tenure** — renters move more than owners. `rented → +2`, `owned → +0`.

Score range: 0–7.

The contributions are hand-specified on purpose. A hand-written scoring function means we know what every person *should* score, so we can verify the system at every step. **The toy's purpose is to test the architecture, not to make accurate social-science predictions.**

**Key vocabulary:**

- **Pipeline rule** — a rule whose body binds inputs, translates them, and computes an output.
- **Derived relation** — a relation computed by a rule, not stored as facts. The score is derived; the age, income, and tenure are stored.
- **Conjunction** — the comma-separated list of goals in a rule body, all of which must succeed.
- **Binding by unification** — when a goal matches a fact, variables in the goal become bound to values from the fact.
- **No mutable variables** — once a variable is bound, it is fixed. You cannot "accumulate" by reassigning. The final `is/2` computes the whole expression at once.
- **Directionality** — arithmetic goals require their inputs to be bound before they run.

### 2. Why (the relevance)

This is the first exercise where the symbolic layer *does the thing*. Previous exercises were mechanics. Here, the rule produces a number that means something about the domain. Alice is 7. Dan is 6. These numbers are not stored anywhere; they are computed. **This is what inference means.**

It's also the first predicate with a multi-step body — bind, bind, bind, translate, translate, translate, compute. That shape is the shape of the Critic's validation rules and the Conductor's query rules. You are learning the universal shape of a reasoning predicate.

And the answers are known in advance, *because we computed them from the facts and rules*. If your rule produces 7, 6, 3, 1, 0, it's correct. If not, you know which component to inspect.

### 3. Do (your task)

**Create a new file `stage_a4.pl`.** Type everything.

**Facts — entities and given attributes:**

```prolog
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
```

**Component predicates:**

```prolog
% Exercise 4 — Score components

age_component(A, 3) :- A < 30, !.
age_component(A, 1) :- A >= 30, A < 50, !.
age_component(A, 0) :- A >= 50.

income_component(low,    2).
income_component(medium, 1).
income_component(high,   0).

tenure_component(rented, 2).
tenure_component(owned,  0).
```

**The main rule:**

```prolog
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
```

**Read it in plain English before running anything:**

> For a person `P` to have mobility score `Score`:
> - find their age `A`,
> - find their income band `I`,
> - find their household `H`,
> - find that household's tenure `T`,
> - translate `A` into component `C1`,
> - translate `I` into component `C2`,
> - translate `T` into component `C3`,
> - and set `Score` to `C1 + C2 + C3`.

**Before you run, work out by hand what each person should score.** Use the facts and the components. Write the five numbers down. Then run.

**Run:**

```prolog
?- mobility_score(alice, S).
?- mobility_score(bob,   S).
?- mobility_score(carol, S).
?- mobility_score(dan,   S).
?- mobility_score(eve,   S).
```

Compare each result to what you computed by hand. If any number differs, **stop and tell me**. Do not accept a number because I said so.

**The enumeration query:**

```prolog
?- mobility_score(P, S).
```

Predict the order of solutions before running. The order follows the order of `age/2` facts in the file, because `age(P, A)` is the first goal in the body and Prolog enumerates `P` in the order it finds them.

**The reverse query:**

```prolog
?- mobility_score(P, 7).
```

Predict: does this work, or does it error? Reason it through. `P` is unbound, `Score` is bound to 7. The body runs: `age(P, A)` binds `P` from the first fact. Then the chain completes. Then `Score is C1 + C2 + C3` — but `Score` is already bound to 7. So `is/2` evaluates the right side and *checks* whether it equals 7. If it does, the query succeeds; if not, Prolog backtracks to try the next person.

This should work and return `P = alice`.

**The deliberate gap test:**

Comment out `income(alice, low).` (add `%` in front). Reload. Run:

```prolog
?- mobility_score(alice, S).
?- mobility_score(P, S).
```

Predict both before running. The first returns `false.` — no error, just failure — because `income(alice, I)` can't be proven. The second quietly drops alice from the results; the other four still appear.

**This is a gap.** The KB is missing a fact, and the reasoning engine reports it as failure, not as a diagnosis. Stage C's gap detector will fix this.

**Put the fact back** before continuing.

### 4. Discuss (what to notice)

**The rule is a pipeline, and the order of goals is not stylistic.** Each goal needs certain variables bound before it runs. `tenure(H, T)` needs `H` from `lives_in(P, H)`. `age_component(A, C1)` needs `A` from `age(P, A)`. `Score is ...` needs all three components. If you reorder, Prolog may error with "Arguments are not sufficiently instantiated".

**The rule is a derived relation.** The score isn't stored; it's computed. This matters because the Critic can check candidates against derived facts, not just stored ones. A candidate fact that *entails* a contradiction with something derivable can be caught, even if no stored fact contradicts it.

**The rule is partially reversible.** `?- mobility_score(P, 7).` works because the final `is/2` becomes a check when `Score` is bound. But `?- mobility_score(P, 100).` fails slowly — Prolog has to exhaust every person before concluding failure.

**The `lives_in` → `tenure` chain is the ontology at work.** Tenure is a property of the *household*, not the person. The rule has to walk two hops: person → household → tenure. This is the first time the ontology's relational structure matters. In the real system, when the LLM extracts facts, the shape of the ontology constrains what it's asked to extract and how extracted facts connect to existing ones.

**The silent failure is the gap.** When `income(alice, I)` can't be proven, the whole rule fails. No message, no diagnostic — just `false.` The gap detector must intercept this, recognise that `income(alice, _)` is missing, and produce a structured diagnostic that drives the LLM to re-extract.

**The asymmetry between component predicates.** `age_component/2` uses arithmetic guards — directional, errors when queried with an unbound age. `income_component/2` and `tenure_component/2` are facts — reversible, enumerable.

**No mutable variables.** If you tried `Score is Score + C1` or reused `C` for all three components, you hit the fundamental property: Prolog variables are bound once. Each distinct value needs its own variable. The final `is/2` sums three already-bound variables in a single expression.

### 5. Report back

When you've done it, tell me:

1. Did the five scores come out matching what you computed by hand?
2. Did `?- mobility_score(P, 7).` work and return alice? What happened with `?- mobility_score(P, 100).`?
3. When you removed `income(alice, low)`, did you get `false.` — and did the enumeration query quietly drop alice?
4. In your own words, what does the rule *do*, operationally, in the order it does it?
5. Anything else that surprised you.

**Then we move to Exercise 5: `findall/3` and `most_likely_to_move/2`** — where the symbolic layer answers the toy's central question for the first time.
