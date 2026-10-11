## Exercise 1: Facts and Queries

### 1. What (the concept)

Prolog programs are built from **facts** and **queries**.

- A **fact** is a statement that something is true. It has the form `predicate(argument1, argument2, ...).` — always ending with a full stop.
- A **query** is a question you ask the Prolog interpreter. It has the same shape as a fact, but you type it at the `?-` prompt.
- When you ask a query, Prolog tries to **unify** it with the facts you've loaded. Unification is the act of matching a query's structure against a fact's structure, binding variables as it goes.

**Key vocabulary:**
- **Atom** — a lowercase name, like `alice` or `person`. In Prolog, atoms are constants.
- **Variable** — an uppercase name, like `P` or `A`. Variables can be bound to values during unification.
- **Arity** — the number of arguments a predicate takes. `person/1` is a predicate named `person` with one argument.

### 2. Why (the relevance)

Every fact in your KB will be shaped like these. Every query the Critic or Conductor runs will be shaped like these. Before we can build an ontology, a reasoning engine, or an LLM interface, you need to have the *feel* of facts and unification back in your fingers. Ten minutes here saves hours later.

### 3. Do (your task)

**Create a file called `stage_a.pl`** and type the following into it. **Type it, don't paste it.** The typo you make and then fix is worth more than the paste that just works.

```prolog
% Stage A — Exercise 1
% Facts about our five persons.

person(alice).
person(bob).
person(carol).
person(dan).
person(eve).

age(alice, 27).
age(bob,   45).
age(carol, 62).
age(dan,   29).
age(eve,   51).
```

**Save the file. Then start the interpreter:**

```bash
swipl stage_a.pl
```

**You'll see the `?-` prompt.** Ask these queries **one at a time**, pressing Enter after each. When a query returns an answer, press `;` (semicolon) to ask for more solutions, or `.` to stop.

```prolog
?- person(alice).
?- person(zed).
?- age(alice, A).
?- age(P, 27).
?- age(P, A), A > 40.
?- age(P, A), A < 30, person(P).
```

**Before you run each query, predict what will happen.** Write your prediction down. Then run it and compare. The gap between prediction and reality is where the learning is.

### 4. Discuss (what to notice)

Once you've run them, notice these things:

- `person(alice).` succeeds with `true.` — Prolog found a fact that matches exactly.
- `person(zed).` fails with `false.` — no fact matches, and Prolog says so *without error*. Failure is normal in Prolog, not exceptional.
- `age(alice, A).` binds `A = 27.` — the variable `A` gets unified with the value in the fact.
- `age(P, 27).` binds `P = alice.` — unification goes both ways. Prolog didn't just "look up alice"; it searched for whoever has age 27.
- `age(P, A), A > 40.` — the comma is logical AND. Prolog finds all `P, A` pairs where `age(P, A)` holds AND `A > 40`. It backtracks through the facts to find them all. Press `;` to see each one.
- `age(P, A), A < 30, person(P).` — the extra goal `person(P)` is a *filter* on the results. Since every person with an age < 30 is also a person, this doesn't change the answer here — but it teaches the pattern: **goals compose conjunctively, and order matters for efficiency.**

**One subtlety:** In `age(P, 27)`, the `27` in the query is not "compared" with the fact's `27` — it is *unified* with it. For atoms and numbers, unification and equality coincide. Later, with variables and compound terms, they won't. That distinction will matter.

### 5. Report back

When you've done it, tell me:

1. What surprised you, if anything?
2. Did any query behave differently from what you predicted?
3. Any errors you hit and how you resolved them?

**Then we move to Exercise 2: Rules.** Don't skip ahead — the sequencing is the pedagogy.
