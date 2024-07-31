Alex:

- improving ADD proof in Dafny
- arbitrary number of rows
- mostly done with soundness
- relies on some sort of extraction
- need to reason about arbitrary traces
- took some time (Danfy: boogie, ...)
- Question: is this wrt some finie state machine for separating instructions ?
- use Dafny for arbitrary rows in the future, and SMT solver for individual instructions
- work with the desugared instructions (Wizard IOP level)
- Question: expand on this


Details
- finite state machine not explicitly mentioned
- lemma for arbitrary trace, use a "find_fragment" to split trace 
- it recognizes where the stamp jumps
- it can separate the padding from the other things
- proves that non-padding fragments have size 16
- proves stuff about the last row
- does current spec allow to insert additions / subtractions into padding ?
    - Olivier: yes and it's a bug : )
    - fixed it in the spec during the call, fixing it in the corset after the call
    - [ ] TODO: fix it in the corset files 

Next step:
- work on new modules as ADD is more or less complete
- focus on SMT stuff, as Dafny has demonstrated that it can handle arbitrary row numbers
    - Question: what does that mean ?
    - approach: make the SMT stuff able to handle arbitrary traces
    - use the state machine stuff
    - go from set of 16 rows to arbitrary traces
    - "find inductive principles automatically and from there go to Dafny proofs"
    - one option: prove everything in SMT but one can have 
    - other option: use Dafny as an external proof checker
    - Dafny requires multiple lemmas
    - SMT allows for better automatization, not write lemmas by hand e.g.
    - inferring inductive predicates to handle the arbitrary row traces
    - "property directed reachability"
    - exploit scaffolding / extractability
    - Dave: finding those inductive predicates won't be straightforward
    - Olivier can provide regular expressions
    - start with those to help
    - sometimes can find proofs on its own, sometimes not
    - inferring loop invariants etc ... Dave: an SMT solver won't do that

Joanne: what does the add module soundness look like ?
Alex: work with a fragment; for soundness assume that constraints are satisfied; verify that if inputs are ok then the outputs should comply with the specification; property verified at the 16th row;

Dave has worked on automation this week
Joanne: refactoring / refactoring, ...
simplify code in preparation for automation
Dave working on the Lisp to Dafny predicate generation
Automatic Lemma Generation in python notebook
hope to get back to the missing constraints next week


Dave: automation
parsing Corset constraints
learning Corset semantics
- what happens when you fall off the edge of the matrix in the constraints?
- Also thinking how to translate into Dafny (bool, loob etc how to convert them into Dafny types)

WRT to using Wizard
- Franklin: you can use the -e (-ee, -eee, etc ...) to display different levels of expansions of the constraints
- until you get to the level of the WIZARD

Link to issue
