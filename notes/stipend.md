- [The `STI` module](#the-sti-module)
  - [Purpose](#purpose)
  - [High level specification](#high-level-specification)
    - [Input columns](#input-columns)
    - [CREATE(2) case](#create2-case)
    - [CALL case](#call-case)
  - [Column and constraint details](#column-and-constraint-details)
    - [CREATE workflow](#create-workflow)
    - [CALL workflow](#call-workflow)
<!-- - [Specify an EC\\_DATA module](#specify-an-ec_data-module) -->

# The `STI` module

## Purpose

The purpose of the present `STI` module is to carry out the computation producing the gas stipend provided to any context spawned through a CALL-type instruction or a CREATE-type instruction.

**Note.** The stipend itself is already claimed (without proof) in the `hub` (or will be, once the update to the `hub` is implemented.) For justification the `hub` will lookup the computation in the STI module, thereby justify the associated values which the `hub` merely claims. Note furthermore that the present module is stateless.

## High level specification

### Input columns

The following are columns that will be imported from the HUB. All of them are trustworthy with the exception of GAS_STIPEND, of course, which has to be justified in the present module.

- INST_TYPE: binary column
- VALUE_TRANSFER: binary column which = 1 only for CALL-type instructions which may transfer value

**Note.** The `hub` module will prefil these out depending on the instruction.

- GAS_UPDT: gas amount available to the execution context just prior to dealing with the current CALL-type or CREATE-type instruction
- GAS_COST: sum of all upfront gas costs associated with the instruction (e.g. static cost, memory expansion cost, hashing cost for CREATE2, account creation cost for CALL-type instruction whose recipient account doesn't exist in the state, warmth cost, value transfer cost ...)
- GAS_HI, GAS_LO: required only for CALL-type instructions, 256 bit stack argument containing the 'max gas stipend' parameter $\mu{s}\big[0\big]$ of the instruction
- VALUE_HI, VALUE_LO: required for CALL-type instructions that take a value parameter (i.e. CALL and CALLCODE)
- GAS_STIPEND: the value which ought to be justified



As far as I understand the stipend computation doesn't depend on the instruction _per se_, only on the instruction type and, in case of CALL-type instructions, on whether the instruction accepts a value parameter. One may thus set, for instance

1. CALL-type (e.g. INST_TYPE = 0)
    1. CALL             (e.g. VALUE_TRANSFER = 1)
    1. CALLCODE         (e.g. VALUE_TRANSFER = 1)
    1. DELEGATECALL     (e.g. VALUE_TRANSFER = 0)
    1. STATICCALL       (e.g. VALUE_TRANSFER = 0)
1. or CREATE-type (e.g. INST_TYPE = 1)
    1. CREATE
    1. CREATE2 

**Note.** The `hub` should have already justified the inequality

$$\textsf{GAS\\_UPDT} \geq \textsf{GAS\\_COST} ~ ( \geq 0 )$$

by means of a lookup to the WCP module. One may thus assume this inequality true. Alternatively one may set up the constraints for that comparison which would provide a short term guarantee of correctness, won't take up that much space but will be dropped later.

### CREATE(2) case

AFAIR one simply has to compute

$$\lambda := L(\textsf{GAS\\_UPDT} - \textsf{GAS\\_COST})$$

Where $L(n) := n - \lfloor n/64 \rfloor$ and impose that

$$\textsf{GAS\\_STIPEND} == \lambda$$

### CALL case

This case starts with the same computation of

$$\lambda := L(\textsf{GAS\\_UPDT} - \textsf{GAS\\_COST})$$

Next one must compare $\lambda$ and the 256-bit integer $\mu{s}\big[0\big]$. This can be done via a lookup to the WCP module. Using the outcome of that comparison one can impose that

$$\textsf{GAS-STIPEND} == \min \big\lbrace \lambda, \mu_{\textbf{s}} \big[ 0 \big] \big\rbrace + 2300 \cdot \textsf{VALUE-TRANSFER} \cdot \big[ \mu_{\textbf{s}} \big[ 2 \big] \neq 0 \big]$$

For more details on the CALL cost computation consult #13


Type = bit (1 or 0 depending on whether it's a CALL type instruction or a CREATE type instruction)
VALUE_LOOKUP_FLAG  = bit, only true for CALL and CALLCODE (since they have value parameters)

## Column and constraint details

There must be the following:
- STAMP column: counts monotonically from 0 to ...
- COUNTER column: zero while STAMP is zero, and as soon as STAMP nonzero it cycles 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, ...
- some instruction specific columns that distinguish between them:
  - VALUE_LOOKUP_FLAG binary column (=1 for CALL and CALLCODE only)
  - TYPE  binary column (for instance `TYPE = 0` for all CALL's and `TYPE = 1` for all CREATE's)

<!-- | INST                   | TYPE    | VALUE_LOOKUP_FLAG | VALUE_HI | VALUE_LO | TRANSFERS_VALUE   | -->
<!-- | :------:                   |  :------: | :------:                               | :------:         | :------:          | :------:                           | -->
<!-- | CALL                   | 0          | 1                                       | v_hi           | v_lo            | $=1 \iff$ value $\neq$ 0       | -->
<!-- | CALLCODE         | 0          | 1                                       | v_hi           | v_lo            | $=1 \iff$ value $\neq$ 0       | -->
<!-- | STATICCALL       | 0          | 0                                       | 0                | 0                 | 0                                   | -->
<!-- | DELEGATECALL | 0          | 0                                       | 0                | 0                 | 0                                   | -->
<!-- | CREATE               | 1          | 0                                       | 0                | 0                 | 0                                   | -->
<!-- | CREATE2             | 1          | 0                                       | 0                | 0                 | 0                                   | -->


| INST         | TYPE     | VALUE_LOOKUP_FLAG | VALUE_HI | VALUE_LO | TRANSFERS_VALUE   |
|--------------+----------+-------------------+----------+----------+-------------------|
| CALL         | callType | 1                 | v_hi     | v_lo     | =1 <=> value != 0 |
| CALLCODE     | callType | 1                 | v_hi     | v_lo     | =1 <=> value != 0 |
| STATICCALL   | callType | 1                 | 0        | 0        | 0                 |
| DELEGATECALL | callType | 1                 | 0        | 0        | 0                 |
|--------------+----------+-------------------+----------+----------+-------------------|


For COUNTER there are two options:
- either have a very specific behaviour, e.g. COUNTER: 0, 1, 2, 3 or 0, 1, 2 or just 0, 1 depending on CALL transfering value, CALL not transfering value or CREATE
- either have generic behaviour: COUNTER: 0, 1, 2, 3 _always_ <--- likely the best option

Have some "counter-constancy" constraints on columns imported from the HUB:
- INST
- GAS_UPDT
- GAS_COST
- GAS_STIPEND
- GAS_HI
- GAS_LO
- VAL_HI
- VAL_LO

We can have some columns that contain the contents of things to look-up else where, e.g.
- LOOKUP_ARG_1_HI
- LOOKUP_ARG_1_LO
- LOOKUP_ARG_2_HI
- LOOKUP_ARG_2_LO
- LOOKUP_RES_HI
- LOOKUP_RES_LO
- LOOKUP_INST
- WCP_SELECTOR: binary column that acts as the selector for data to send to WCP
- MOD_SELECTOR: binary column that acts as the selector for data to send to MOD

**Note.** The high parts of all inputs are zero except for when comparing GAS = $\mu_\textbf{s}\big[0\big]$ with $L(\cdots)$. The High part of all results will always be zero. We could therefore kill the following:
- LOOKUP_ARG_2_HI
- LOOKUP_RES_HI

The idea would be that one has
- WCP_SELECTOR * EXT_SELECTOR = 0
- If STAMP = 0 Then WCP_SELECTOR + MOD_SELECTOR = 0 (i.e. both are zero)
- If WCP_SELECTOR = 1 Then LOOKUP_INST $\in$ { LT, ISZERO } (i.E. we can only request LT and ISZERO instuctions)
- If MOD_SELECTOR = 1 Then LOOKUP_INST = DIV (i.e. we can only request the DIV from MOD)

### CREATE workflow

- CT = 0: compare GAS_UPDT with GAS_COST

_If_ the above comparison worked with the desired comparison bit _Then_

- CT = 1: 1/64th computation (with a single CALL to MOD module using the DIV instruction and argument GU - GC and 64 which gives you the floor.)
	**Note.** The RES_HI / RES_LO columns for the MOD lookup will contain the \lambda := L(GU - GC)

You should only require 2 rows so if you have a counter that always counts to 3 you would be idle for the next 2 rows

### CALL workflow

- CT = 0: compare GAS_UPDT with GAS_COST (for all instructions)

_If_ the above comparison worked with the desired comparison bit _Then_

- CT = 1: 1/64th computation (with a single CALL to MOD module using the DIV instruction and argument 1 being GU - GC and argument 2 being 64 - this gives you the desired floor.)

**Note.** The RES_HI / RES_LO columns for the MOD lookup will contain the $\lambda$ := L(GU - GC)

- CT = 2: compute the minimum (for all CALLs calling to WCP with LT instruction)
- CT = 3: compare GAS_UPDT with GAS_COST (for CALLs that may transfer value calling WCP with the ISZERO instruction)
