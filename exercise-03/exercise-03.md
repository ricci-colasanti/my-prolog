*Thank you — and noted. Here's Exercise 3, corrected and clean.*

---

## Exercise 3 (Corrected): Arithmetic Rules and the Directional Error

### 1. What (the concept)

Two things, and only two things, are the point of this exercise.

**First: `=` versus `is`.**

- `=` is **unification** — structural matching, no arithmetic. `X = 2 + 3` binds `X` to the *term* `2 + 3`, not to `5`.
- `is` is **arithmetic evaluation**. `X is 2 + 3` binds `X` to `5`.

You will use `is` in Exercise 4 to sum the score components. If you use `=` by mistake, you'll build a term instead of computing a number, and everything downstream will break in confusing ways.

**Second: arithmetic is directional.**

The comparison operators `<`, `>`, `>=`, `=<`, `=:=`, `=\=` all *evaluate* their arguments. Both sides must be **ground** (bound to actual numbers) at the moment of evaluation. If either side is an unbound variable, Prolog throws:

```
ERROR: Arguments are not sufficiently instantiated
```

This is not a bug. It's how arithmetic works. `<` is a computation, not a relation. You can feed it numbers and get a truth value. You cannot feed it an unbound variable and ask "which values would make this true?" — because that set is effectively infinite, and `<` doesn't enumerate.

**The practical consequence:** a rule containing arithmetic works *forward only*. Feed it bound inputs, get outputs. Call it with unbound inputs, get an error.

### 2. Why (the relevance)

`mobility_score/2` — the heart of the toy — is assembled from three component predicates. One of them, `age_component/2`, uses arithmetic guards. The other two are facts (no arithmetic). The asymmetry between them matters enormously later, when the gap detector needs to know which predicates are fillable by extraction and which are not.

But that's Exercise 4's concern. **This exercise is only about getting the arithmetic rule right, and learning to recognise its error when you trip it.**

### 3. Do (your task)

**Create a new file `stage_a3.pl`.** Type exactly this — nothing more:

```prolog
% Exercise 3 — Facts about ages

age(alice, 27).
age(bob,   45).
age(carol, 62).
age(dan,   29).
age(eve,   51).

% Exercise 3 — Age components

age_component(A, 3) :- A < 30, !.
age_component(A, 1) :- A >= 30, A < 50, !.
age_component(A, 0) :- A >= 50.
```

**Save, load `swipl stage_a3.pl`, and run these queries. Predict before running.**

**Group A — ground input, the rule works forward:**

```prolog
?- age_component(27, C).
?- age_component(29, C).
?- age_component(30, C).
?- age_component(45, C).
?- age_component(50, C).
?- age_component(62, C).
?- age_component(100, C).
```

**Group B — deliberate error:**

```prolog
?- age_component(A, C).
```

Read the error. It should say "Arguments are not sufficiently instantiated". Understand: `A` is unbound, the guard `A < 30` cannot be evaluated, Prolog cannot proceed.

**Group C — the compositional pattern (this is the shape the Conductor will use):**

```prolog
?- age(alice, A), age_component(A, C).
?- age(P, A), age_component(A, C).
```

The first binds `A` from alice's fact, then computes her component. The second enumerates all persons — bind from the KB, then compute. This is the "bind, then evaluate" pattern. Learn to see it; you'll write it a hundred times.

**Group D — exploring `=` vs `is` at the prompt:**

```prolog
?- X = 2 + 3.
?- X is 2 + 3.
?- 5 > 2 + 1.
?- 5 =:= 2 + 3.
?- X = 5, X > 2.
?- X > 2, X = 5.
```

**Predict each of the last two carefully.** In the first, `X` is bound to 5 *before* the comparison, so `5 > 2` succeeds. In the second, `X > 2` is evaluated with `X` unbound, and it **errors** — the same "not sufficiently instantiated" error. Order of goals in a conjunction matters when arithmetic is involved.

### 4. Discuss (what to notice)

- **`is` evaluates, `=` unifies.** `X is 2 + 3` gives `X = 5`. `X = 2 + 3` gives `X = 2+3` (the term). This will bite you in Exercise 4 if you forget.

- **Arithmetic is directional.** Every rule with `<`, `>`, `=<`, `>=`, `=:=`, or `=\=` requires its arithmetic inputs to be bound. This is not a Prolog quirk to work around — it's what arithmetic *is*. A comparison is a computation; it needs its operands.

- **The error is a landmark.** "Arguments are not sufficiently instantiated" always means the same thing: some part of your query tried to evaluate arithmetic on an unbound variable. The fix is always the same: ensure the variable is bound *before* the arithmetic goal runs.

- **Order matters in arithmetic conjunctions.** `X = 5, X > 2` works. `X > 2, X = 5` errors. Both are "logically" equivalent in a mathematical sense, but operationally different because Prolog evaluates goals left to right, and `>` needs `X` bound when it runs.

- **The compositional pattern is what the Conductor will use.** `age(P, A), age_component(A, C)` is a miniature version of every query the reasoning engine will answer: bind facts from the KB, then compute derived values. Get this pattern into your fingers.

- **Cuts make the intent explicit.** Our age bands are mutually exclusive by construction, so cuts aren't strictly required here. They're a style choice: "first match wins, commit." You'll see this pattern everywhere in scoring-style predicates.

### 5. Report back

When you're done, tell me:

1. Did the "not sufficiently instantiated" error feel *expected* this time, rather than mysterious?
2. When you ran `?- age(P, A), age_component(A, C).`, did the results match your predictions?
3. Did `?- X > 2, X = 5.` error, as I said? If so, can you articulate *why* in your own words?
4. Anything else that surprised you.

**Then we move to Exercise 4: The Full Score** — where `age_component/2` meets `income_component/2` and `tenure_component/2`, and `mobility_score/2` produces the numbers 7, 6, 1, 0, 0 that this whole toy was designed around. That's the exercise where the symbolic layer first *does the thing*.

---

*Take your time. No rush. The exercises are small on purpose — the goal is depth, not coverage.*
