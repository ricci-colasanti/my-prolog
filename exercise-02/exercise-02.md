## Exercise 1 Summary — Facts and Queries

**What you learned:**
- **Facts** are `predicate(arg1, arg2, ...).` statements — the raw data of a Prolog program.
- **Queries** are questions asked at the `?-` prompt, shaped like facts but with variables where you want to search.
- **Unification** is the core mechanism: Prolog doesn't "compare" or "look up" — it tries to make the query and a fact *structurally identical* by binding variables. It's bidirectional, symmetric, and fails cleanly when it can't.
- **Conjunction** is the comma: `age(P, A), A < 30` means "find P, A such that age holds AND A < 30".
- **Failure is normal** — `person(zed).` returning `false.` is not an error, it's Prolog saying "no fact matches".
- **Backtracking** — pressing `;` asks Prolog to try the next unification. This is Prolog exploring the search space.
- **Grounded vs. open queries** — `young(moby)` checks a specific thing; `young(P)` enumerates all things. Same rule, different calling convention. This distinction is the Critic-vs-Conductor split in miniature.

**What you did:**
- Typed facts for five (now six — hello, Moby) persons.
- Ran six queries and observed unification, filtering, and multi-solution search.
- Extended the KB with a new entity and re-queried.
- Asked how to test identity — and got the search/check/compose distinction in return.

**The habit to keep:** predict before you run. The gap between prediction and reality is the learning.

---

## Exercise 2: Rules — The Inference Habit

### 1. What (the concept)

A **rule** is a statement of the form:

```prolog
head :- body.
```

Read it as: *"head is true if body is provable."* Or: *"to prove head, prove body."*

The **head** is a predicate you're defining. The **body** is a conjunction of goals that must all succeed for the head to succeed. The `:-` is called the **neck** — it separates what you're defining from what proves it.

A rule is a *generalisation over facts*. Where a fact says "alice is an adult", a rule says "anyone is an adult if their age is at least 18". The rule *derives* conclusions from facts.

**Key vocabulary:**
- **Clause** — a generic term for either a fact or a rule. Both are clauses; a fact is just a rule with an empty body.
- **Predicate** — a named collection of clauses sharing the same name and arity. `age/2` is a predicate; `age(alice, 27).` is a clause within it.
- **Provable** — a goal is provable if Prolog can find a chain of clauses that unifies it successfully.

### 2. Why (the relevance)

Rules are the entire point of the reasoning engine. Every domain inference you'll write — the scoring function, the derived relations, the integrity constraints — is a rule. Facts alone are just a database; rules turn a database into a knowledge base. Exercise 1 taught you to *store*; Exercise 2 teaches you to *infer*.

The specific skill here is getting comfortable with the rule shape and how a rule *fails* when a subgoal can't be proven. That failure behaviour is what the Critic and the gap detector will rely on.

### 3. Do (your task)

**Create a new file `stage_a2.pl`** (or add to `stage_a.pl` — your choice; I'd start fresh so Exercise 1 stays clean and re-runnable).

**Type these facts (reuse them from Exercise 1, retyped — the repetition is the point):**

```prolog
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
```

**Now add these rules:**

```prolog
% Exercise 2 — Rules

adult(P) :- age(P, A), A >= 18.

young_adult(P) :- age(P, A), A >= 18, A < 30.
```

**Save, reload the interpreter (`swipl stage_a2.pl`), and run these queries one at a time. Predict first, then run:**

```prolog
?- adult(alice).
?- adult(moby).
?- adult(tom).
?- young_adult(P).
?- adult(P), \+ young_adult(P).
?- adult(P), young_adult(P).
```

**Then deliberately break something.** Add this fact to the file:

```prolog
age(bob, 99).
```

Reload. Run `?- age(bob, A).` and press `;` to see all solutions. Then run `?- adult(bob).` and `?- young_adult(bob).`

**What to notice:** Prolog now has *two* ages for bob. Query `age(bob, A)` returns both. Query `adult(bob)` succeeds (using one of them, or both on backtracking). This is the "add a fact, affect every query" property you discovered with Moby — now applied to a contradictory fact. **This is exactly why the Critic exists.** In the real system, a candidate fact from the LLM that contradicts an existing one must be caught before assertion.

**Then remove the `age(bob, 99).` fact** (or comment it out) before continuing.

### 4. Discuss (what to notice after you run)

- `adult(alice).` → `true.` because `age(alice, 27)` and `27 >= 18`.
- `adult(moby).` → `false.` because `3 >= 18` fails. Not an error, just failure.
- `adult(tom).` → `false.` because `age(tom, _)` can't be proven at all — tom has no age fact. **Failure of the body propagates to failure of the head.**
- `young_adult(P).` → enumerates alice and dan only. Moby fails the `>= 18` test; bob, carol, eve fail the `< 30` test.
- `adult(P), \+ young_adult(P).` → bob, carol, eve. The `\+` is negation-as-failure: "P is adult AND P is not young_adult". This is how you express "the middle-aged and older adults".
- `adult(P), young_adult(P).` → alice, dan. Both predicates succeed for the same person; the conjunction filters to the intersection.

**The subtle one:** when `age(bob, 99)` is added, `adult(bob)` *still succeeds* — but now it has two possible proofs. Press `;` after `true.` and you'll see `true.` again (or possibly the same proof twice, depending on how SWI collapses duplicates). This is the "multiple proofs" behaviour of Prolog that you'll exploit later for gap detection: a goal can have zero, one, or many proofs, and *how many* is sometimes as important as *whether*.

### 5. Report back

When you've done it, tell me:

1. Did the `\+` operator surprise you? Negation-as-failure means "cannot be proven", which is subtly different from "is false".
2. What happened when you added `age(bob, 99)` — did `adult(bob)` succeed once, twice, or something else?
3. Any predictions you got wrong?

**Then we move to Exercise 3: Arithmetic and Components** — where we start building the actual `mobility_score/2` machinery.
