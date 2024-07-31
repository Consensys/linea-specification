# Meeting notes 2023.11.09

## Alex

Wrote a specification for TRM
BMC found bugs ?
TRM should detect precompiles; seems like 16 is recognized as precompile; not 100% sure
Also: there are binary constraints that are missing

Olivier:
- spec updated, see [commit 14c26a5d19f4375c6ac05ace010048638fe826b2](https://github.com/Consensys/zkevm-spec/commit/14c26a5d19f4375c6ac05ace010048638fe826b2) on the spec repo
- corset constraints updated, see [TRM: missing binary constraints](https://github.com/Consensys/zkevm-constraints/pull/38)

**BMC (Branching Model Checking)** implemented as sample code.
It is based on temporal logic.
**Idea**
- have some notion of branching time
- in bounded model checking we fix the number of rows, but
  - we could have all padding rows
  - we could have padding + non-padding rows
- we can branch on that dichotomy by making distinction between the two cases.

Partially solves the problem of determining the lengths we want to check.

We need some sort of **dual notion of reachability** (reachability in the opposite direction ?)
Related to "predictions"
We don't have time in setting, but we can "invent" time notion in our setting.
Adding rows corresponds to doing a computation
Predictions break this (locally non-deterministic)
For constructing rows we can produce whatever we want. But this clashes with future constraints (e.g. target constraints)
Building traces row by row seems natural, but one should be able to **look ahead** to predict the result ahead (e.g. 15 rows in the future.)
To solve this one could add several rows at a time.
One can also see it as knowing both the first and last row of a chunk at the start.
State transition system language is compatible with the forward looking / backwards looking approaches
Dual reachability says: we have a trace that satisfies constraints

Does that mean that the constraints have to be reinterpreted ?
E.G. STAMP_{i + 1} \in STAMP_{i}, 1 + STAMP_{i}
This can be interpreted in two directions
Having the two interpretations makes checking faster as there is more information available.
This is because e.g. if you have 17 rows in bounded model checking then you don't know whether you are in one scenario or another (e.g. all padding or one padding row followed by an actual instruction.) 

## Joanne

Finished completeness for ADD module (previously missing SUB instruction)
Completeness is solved for that module.
**Completeness:**
- you can build any trace for any sequence of (ADD/SUB) instructions
- arbitrary ARG1 / ARG2 and arbitrary instructions
- working from the honest prover perspective

New trace mechanism. More on that later.
This new trace mechanism will be adapted to older modules
Advantage of this tracing mechanism: it's fast to prove: under 60 seconds
E.G. Helper for byte decompositions

### New trace mechanism

Still doing induction starting with an empty trace.
Idea remains that adding another set of rows keeps valid trace valid.
The stuff you are adding, the delta, is now so that you only need to check it.
You are being more assertive about the properties of the existing trace. 
You can send in the whole trace table or the update to the trace table.

Olivier: what about the constraints that link one chunk of trace to the next ? E.g. those that live at the threshold of one chunk of rows to another, where one chunk of rows represents a give computation.
Joanne: In ADD module and others Heartbeat constraints are the linking constraints.
Dafny was struggling with them for some reason.
This approach is better for Dafny.
"Assume all constraints hold on the previous trace, prove that the updated trace still satisfies constraints"
In the past "all" was for instance replaced with a subset of the constraints such as the "heartbeat"

David's focus is on the LISP to Dafny.
The more aggressive part of the verification is generic and can be ported to other modules and can be incorporated in the automation part.
This is based on some python notebooks ...

Should try something new with next module (e.g. MUL and the EXP opcode.)

Going back to older modules to apply these modifications to older modules.

## Olivier

Recommendation: there are two pathways forward:
- either tackle one of the more complex stateless modules (e.g. MUL which deals with the MUL and EXP opcodes, the latter which can take anywhere from 1 row to (any nonzero module of 8 less than or equal to 2*256*8 =) 4096 rows per EXP opcode)
- or tackle a stateful module (e.g. MXP which tracks WORDS / WORDS_NEW (the number of active words of an execution context) and C_MEM / C_MEM_NEW (the cost of memory expansion up to that point)); it may pay off to deal with only a subset of the covered instructions for such a module (e.g. with MXP one could start with MSTORE / MSTORE8 and MLOAD only)
