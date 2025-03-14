# Friday 2023.11.03

Alex:
Other style of proof checking (~PROPERTY DIRECTED~ REACHABILITY approach)
- written in Dafny 
related with "inductive invariants"
Wrote prototype for stripped down module (0-3 for simplification)
- requires defining many states and their transitions 
	- states that are reachable in 1, 2, ... steps
	- check whether certain predicates are inductive
	- E.g. a state F4 which is defined by either STAMP = 0 or nonzero and CT = 0, 1, 2, 3.
	- this state is inductive (once you are in there, you should remain there
	- you have predicates for "Forward rechability" and "Backward reachability"
	- and you prove that when you are a fwd and bwd reachable state you satisfy the spec
- this approach tries to deal with both the scaffolding and the functional correctness
	- prove specification based on summaries (B3, F4 predicates)
	- these could be rich enough to prove specification
	- goal: build these predicates automatically
- what is the upshot of Reachability approach ?
	- property directed reachability
	- state transition style approach where each row is a state
	- initial state, final state
	- you have a transfer function from one state to the next
- is that an alternative approach to dafny theorem proving / z3 SMT solving ? 
	- it is written in Dafny
Could rewrite stuff in that style
ADD module looks into the future mostly but also into the past for OVERFLOW
- makes it difficult to apply state transition approach
- State could be 2 consecutive rows
- real issue ?
	- Olivier: we could write all constraints to be forward looking
	- Franklin: this would be interesting for the padding business for Corset, but also for Alex for the formal verification
This approach lends itself to
- Looking for "trivial" counter examples using simple predicate calculus
- Then build a symbolic trace which can then be instantiated


This vs other approach:
in reachability we extract summary to do actual proof
in the other approach we need more (constraint satisfaction or so up ot this point)

NEXT STEPS:
- write ADD (real module) proof in this style

Experiment with PREDICATE ABSTRACTION
So that in ADD module we can just analyze 17 rows or so and abstract the statement and infer inductive stuff from that
Should work for ADD module
Related to state machine stuff
We have basically 16 predicates
- is padding a predicate ?
- every CT value is its own predicate ? 
Counterexample finding stuff

Did BOUNDED MODEL CHECKING Prototype
- Do you need to predict the combinatorics of the module ? What instructions can come up and in what order ?
	- requires predicting the combinatorics of the module
- for ADD module use limits of 33 = 1 + 16 + 16
	- write model checker for that "representative" combinatorics 
Instantiating module
First and last row must be satisfied.
- what do you get with this approach ?
- E.g. if there are several instructions
Also tried to apply this to TRM module
Going from BMC to arbitrary traces:
- BMC for "useful samples" of a trace
- extract properties that should hold
- prove that these are inductive properties
- predicate abstraction works with arbitrary traces

Valentin: use Horn encoding stuff for Z3

Alex: "directed reachability"

David:
- EF project focus

Joanne:
- helper proofs for WCP and ADD module
- one away for ADD module to satisfy completeness
- done progress on WCP module
- automation: pattern extracted from proofs
- forward looking of constraints would help a lot
