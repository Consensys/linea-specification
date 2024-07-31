- [Preliminary questions](#preliminary-questions)
- [More detailed questions](#more-detailed-questions)
  - [Simple constraint systems perform computations as advertized](#simple-constraint-systems-perform-computations-as-advertized)
  - [Type system](#type-system)
  - [ROLLBACK-yoga:](#rollback-yoga)
  - [DEPLOYMENT\_NUMBERS, DEPLOYMENT\_STATUS handles reverts, selfdestructs correctly](#deployment_numbers-deployment_status-handles-reverts-selfdestructs-correctly)
  - [Evolving spec \& formal verification](#evolving-spec--formal-verification)
  - [Lofty goals](#lofty-goals)


# Preliminary questions

- What do we **want** formally verified ?
- What questions **can** and **should** formal verification methods be applied to ?
- When is testing **better** ?

# More detailed questions 

## Simple constraint systems perform computations as advertized

- arithmetic, comparisons, binary, trimming, ...
- oob, mxp, ...

## Availability (lookups work)

- DATA is available elsewhere
- Some modules should ONLY do some determined things (how to prevent phantom tx's etc ...)

## Type system

(boolean, bytes, various kinds of smallness of integers: $\leq 4, 8, 16)$-byte integers)

## ROLLBACK-yoga:

- handling several different REVERT stamps and offsets
- standard offsets e.g. for reverting account / storage operations, for enacting SELFDESTRUCTs after everything else has been done (dom, sub) = (tau * stamp + offset, tau * hub + small)
    - strange example: the COINBASE is a smartcontract and it is SELFDESTRUCT'ed: which wins: the refund ? the wiping of the account ? 
- revert through the COLUMN, COLUMN_NEW paradigm
- revert through the paradigm of "don't change it if it will be reverted (refunds)"
- **Question.** To what extent can simple designs like those below be formally verified pre-implementation ?

without reverts:

| REV_STAMP | STAMP | DOM             | SUB | VAL | VAL_NEW | WAL | WAL_NEW |
| --------- | ----- | --------------- | --- | --- | ------- | --- | ------- |
| 0         | h     | $\tau \cdot$ h  | 0   | v   | v'      | w   | w'      |
| ...       | ...   | ...             | ... | ... | ...     | ... | ...     |
| 0         | h'    | $\tau \cdot$ h' | 0   | v'  | v''     | w'  | w''     |

with reverts

| REV_STAMP | STAMP | DOM               | SUB             | VAL | VAL_NEW | WAL | WAL_NEW |
| --------- | ----- | ----------------- | --------------- | --- | ------- | --- | ------- |
| $\rho$    | h     | $\tau \cdot$ h    | 0               | v   | v'      | w   | w'      |
| $\rho$    | h     | $\tau \cdot \rho$ | $\tau \cdot$ h  | v'  | v       | w'  | w'      |
| ...       | ...   | ...               | ...             | ... | ...     | ... | ...     |
| $\rho$    | h'    | $\tau \cdot$ h'   | 0               | v'  | v''     | w'  | w'      |
| $\rho$    | h'    | $\tau \cdot$ h'   | $\tau \cdot$ h' | v'' | v'      | w'  | w'      |

with several revert stamps

| REV_STAMP_1 | REV_STAMP_2 | STAMP | DOM                  | SUB                | VAL | VAL_NEW | WAL | WAL_NEW |
| ----------- | ----------- | ----- | -------------------- | ------------------ | --- | ------- | --- | ------- |
| $\rho\_1$   | $\rho\_2$   | h     | $\tau \cdot$ h       | 0                  | v   | v'      | w   | w'      |
| $\rho\_1$   | $\rho\_2$   | h     | $\tau \cdot \rho\_1$ | $\tau \cdot$ h + 1 | v'  | v       | w'  | w'      |
| $\rho\_1$   | $\rho\_2$   | h     | $\tau \cdot \rho\_2$ | $\tau \cdot$ h + 2 | v   | v       | w'  | w       |
| ...         | ...         | ...   | ...                  | ...                | ... | ...     | ... | ...     |
| $\rho\_1$   | 0           | h'    | $\tau \cdot$ h'      | 0                  | v'  | v''     | w'  | w'      |
| $\rho\_1$   | 0           | h'    | $\tau \cdot\rho\_1$  | $\tau \cdot$ h'    | v'' | v'      | w'  | w'      |

![Flowchart for CREATE-type instructions](https://hackmd.io/_uploads/Bk_sggBy6.png)

![Flowchart for CALL-type instructions (not to precompile)](https://hackmd.io/_uploads/HJN0xlBk6.png)

## DEPLOYMENT_NUMBERS, DEPLOYMENT_STATUS handles reverts, selfdestructs correctly

- they transit as expected from ACCOUNT-rows to CONTEXT-rows to STORAGE-rows

## Evolving spec & formal verification

- what is the role of formal verification with an evolving spec ? with an evolving back end ?
    - bug fixing in spec
    - philosophy changes (counter-constancy vs. IOMF/DONE) paradigm)
    - major updates (e.g. v1 -> v2) of modules
    - reinterpretation of constraints (field change)
    - field agnostic zk-evm
    - **Question** To what extent is the formal verification dependent on the constraints ? Joanne's approach isn't scalable --- what approach is ? What are the properties that can a more or less implementation independent formal proof which can be updated as spec changes roll in ? 
    - How to **automatize** lisp -> (dafny / coq / ...) so that formal verification of properties survives ? 
- when is an appropriate time to think of formal verification ?
    - e.g. recent redesign of CALL's CREATE's
    - simplified design underpinned by less contrived constraints 

## Lofty goals

- catching the possibility of valid yet **undesirable traces** (i.e. catching underconstrained systems with negative consequences: recent example of a monotone column that could respect nondecreasing conditions but behave badly because of the possibility of starting out negative
- **Completeness** (lofty goal):
    - valid traces are always producible given a valid input state and valid (''relatively cheap'') transactions
    - for all Soundness, "compliance with the EVM", control flow of complex opcodes (e.g. CALLs, CREATEs, precompiles) ...
- **Soundness** (lofty goal):
- Can we use the zk-evm as a kind of **execution client** ?
    - Comparisons with other clients, e.g.
        - abstract away the hashing and other precompiles 


# Notes

Using firsts order logic to test the logic of a program before implementation.
- prove existence / non existence of solutions.
- working with finite universes of possibilities


## Ever evolving spec

- transpilation
- 2 main theorems: soundness and completeness
- rather than function, think of relations (several outputs are alright);w

## Automation

- EVM execution spec
    - If statements
    - 3 loops or so in total
- ZKEVM corset constraints
    - while loops (RLP while nonzero, MMU: for (i = 0; i < ...; i++)

Have a path from both to a CL (common logic) ?
- Using 1st order logic (for simple modules: Exists unique trace)

## Proof automation strategy

Suppose we can transform theorem to CNF

Modal logic: has an intrinsic notion of state and a notion of temporality.

Question: is there a duality between constraints and computations (CT columns are while loops)

Computations:
- essential uniqueness of traces
- modeling the computation as a DAG
    Note: we have some circularity in the constraints:
    - CFI is referenced in the CALL's
    - CFI is only resolved at the end of the computation
    - reflection of the result in the TRACE (HUB)
- actually: there is some circularity
- notion of essential uniqueness, see PIC 1

Incremental approach producing trusted black boxes:
- outside ones (ECRECOVER, SHA3, ...)
- ones that are formally verified from our arithmetization


Using constraints to generate irectd graph of computational dependencies between columns.
Use this to generate traces automatically. 
Constraints satisfaction problems and finding solutions to constraints
