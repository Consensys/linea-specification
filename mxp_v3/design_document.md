# MXP module redesign

let LMMS = 256^4 (linea max memory size)

| INST             | LCIB | LCIW | CN ⟦ π ⟧ | OFFSET_1 ⟦ π ⟧ | OFFSET_2  ⟦ π ⟧ | SIZE_1  ⟦ π ⟧ | SIZE_2  ⟦ π ⟧ | DEPLOYING ⟦ π ⟧ | RES ⟦ π ⟧ | MXPX ⟦ π ⟧ | GAS_MXP ⟦ π ⟧ | WORDS   | WORDS_NEW   | C_MEM   | C_MEM_NEW   | LIN_COST   | QUAD_COST   | MAX_OFFSET  | EXPANSION_REQUIRED |
| ---------------- | --   | --   | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| MSIZE            |      |      |          | ∅              | ∅               | ∅             | ∅             |                 |           | ∅          | ∅             |         |             |         |             | ∅          | ∅           | ∅           | ∅                  |
| ---------------- | --   | --   | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| MLOAD            |      |      |          |                | ∅               | 32            | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |                                                    |
|                  |      |      |          |                |                 |               |               |                 |           |            |               |         |             |         |             |            |             |             |                    | - callWcpLT on SIZE_1 and LMMS                     |
|                  |      |      |          |                |                 |               |               |                 |           |            |               |         |             |         |             |            |             |             |                    | .   ⇒ small_offset                                 |
|                  |      |      |          |                |                 |               |               |                 |           |            |               |         |             |         |             |            |             |             |                    | - if SIZE_1 < LMMS then compute memory expansion   |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        | -------------------------------------------------- |
| MSTORE           |      |      |          |                | ∅               | 32            | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| MSTORE8          |      |      |          |                | ∅               | 1             | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| CREATE           |      | 1    |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | EIP-3860   |             |             |                    |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| CREATE2          |      | 1    |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             |            |             |             |                    |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| RETURN           | 1    |      |          |                | ∅               |               | ∅             | T               | ∅         |            |               |         |             |         |             |            |             |             |                    |
| RETURN           | 1    |      |          |                | ∅               |               | ∅             | F               | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| REVERT           | 1    |      |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| LOG-type         | 1    |      |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| SHA3             |      | 1    |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| CALLDATACOPY     |      | 1    |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| RETURNDATACOPY   |      | 1    |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| CODECOPY         |      | 1    |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| EXTCODECOPY      |      | 1    |          |                | ∅               |               | ∅             |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |
| MCOPY            |      | 1    |          |                |                 |               | ≡ SIZE_1      |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| CALL-type        |      |      |          |                |                 |               |               |                 | ∅         |            |               |         |             |         |             | ∅          |             |             |                    |
| ---------------- | ---  | ---  | ----     | ----------     | ----------      | --------      | --------      | -----------     | -----     | ------     | ---------     | ------- | ----------- | ------- | ----------- | ---------- | ----------- | ----------- | -----------        |

Note. Absent from the above are the following columns that are predictions from the HUB:
    - macro/T4MTNTOP   // useful for anything that touches memory but with potentially zero size
    - macro/S1NZNOMXPX
    - macro/S2NZNOMXPX
Note: the last two are only useful for CALL's and RETURN/REVERT i.e. those opcodes that either set a CALL_DATA_SIZE or a RETURN_DATA_SIZE that may be nonzero in the HUB

3 types of instructions
- the pre-processing of 

These are 

MACRO
PREPROCESSING (MSIZE will never require this, but it may be simpler to have a single trivial preprocessing row regardless)
EXPANSION (single row if COMPUTATION_REQUIRED = false)
    - MAX_OFFSET, by way of examples:
        - MLOAD: OFFSET_1 + 31
        - MSTORE8: OFFSET_1
        - COPY instruction:
            - 0 if the size is zero
            - OFFSET_1 + (SIZE_1 - 1) otherwise
    - compute μ' ↔ WORDS_NEW
        - SIZE ≡ 0
        - SIZE ≠ 0
    - the EXPANSION phase has 2 modes of functioning

MACRO ==> PREPROCESSING ==> EXPANSION
    - in an instruction dependent way, and on the final row of the pre-processing, we decide whether or not we require 
    - there are two possibilities for the PREPROCESSING: note that pre-processing is trivial for MSIZE
        - depends purely on the instruction (we don't optimize for ROOB/NOOP/...)
        - we will have a simple rule to set CT_MAX in this phase purely dependent on INST
        - MEMORY_EXPANSION_COMPUTATION_REQUIRED
    - there are two possibilities for the EXPANSION: trivial (MSIZE, or EXPANSION_REQUIRED ≡ false)
        - we update the number of active WORDS in memory (or keep it the same)
        - we update the MEMORY_EXPANSION_COST for everything up until this point (or keep it the same)



| INST           |  WORD_PRICING | BYTE_PRICING | SINGLE_MAX_OFFSET | DOUBLE_MAX_OFFSET |
|----------------|:-------------:|:------------:|:-----------------:|:-----------------:|
| MSIZE          |               |              |                   |                   |
| MLOAD          |               |              |         1         |                   |
| MSTORE         |               |              |         1         |                   |
| MSTORE8        |               |              |         1         |                   |
| CREATE         | [if EIP-3860] |              |         1         |                   |
| CREATE2        |       1       |              |         1         |                   |
| RETURN         |               |       1      |         1         |                   | is_deployment ≡ true  |
| RETURN         |               |              |         1         |                   | is_deployment ≡ false |
| REVERT         |               |              |         1         |                   |
| LOG-type       |               |       1      |         1         |                   |
| SHA3           |       1       |              |         1         |                   |
| CALLDATACOPY   |       1       |              |         1         |                   |
| RETURNDATACOPY |       1       |              |         1         |                   |
| CODECOPY       |       1       |              |         1         |                   |
| EXTCODECOPY    |       1       |              |         1         |                   |
| MCOPY          |       1       |              |                   |         1         |
| CALL-type      |               |              |                   |         1         |


In terms of lookups, we require:
    - ISZERO checks (into WCP)
    - LT     checks (into WCP) between anything
    - LT     checks (into WCP) against LMMS
    - DIV    computations (by 32  into MOD, potentially into EUC)
    - DIV    computations (by 512 into MOD, potentially into EUC)
    - lookup into the instruction decoder

ID ← duplicate the INST value and instruction decode the ID columns (1 row)
    - decoder/INST
    - decoder/IS_WORD_PRICING
    - decoder/IS_BYTE_PRICING
    - decoder/IS_MSIZE
    - decoder/IS_RETURN
    - decoder/IS_REVERT (?)
    - decoder/IS_CALL
    - decoder/SINGLE_MAX_OFFSET_COMPUTATION_REQUIRED
    - decoder/DOUBLE_MAX_OFFSET_COMPUTATION_REQUIRED
    - decoder/G_WORD
    - decoder/G_BYTE

MACRO (1 row)
    - macro/INST
    - macro/OFFSET_1/2_HI/LO
    - macro/SIZE_1/2_HI/LO
    - macro/DEPLOYING
    - macro/RES
    - macro/MXPX
    - macro/GAS_MXP
    - macro/MAY_TRIGGER_NONTRIVIAL_MMU_OPERATION
    - macro/S1NZNOMXPX
    - macro/S2NZNOMXPX

SCENARIO  (1 row) (to distinguish between the 6 possible scenarios)
    - scenario/MSIZE
         - MSIZE
    - scenario/FIXED_SIZE_INSTRUCTIONS
         - MLOAD, MSTORE, MSTORE8
    - scenario/WORD_PRICING_AND_SINGLE_MAX_OFFSET
         - CREATE, CREATE(2), CALLDATACOPY, RETURNDATACOPY, CODECOPY, EXTCODECOPY, SHA
    - scenario/BYTE_PRICING_AND_SINGLE_MAX_OFFSET
        - RETURN, REVERT, LOG, 
    - scenario/WORD_PRICING_AND_DOUBLE_MAX_OFFSET
        - MCOPY
    - scenario/BYTE_PRICING_AND_DOUBLE_MAX_OFFSET
        - CALL-type
    - scenario/WORDS
    - scenario/WORDS_NEW
    - scenario/C_MEM
    - scenario/C_MEM_NEW

COMPUTATION (depending on the previous flags, including the expansion computation which we perform first)
    - computation/WCP_FLAG
    - computation/MOD_FLAG
    - computation/ARG_1/2_HI/LO
    - computation/RES_HI/LO
    - computation/EXO_INST

CT
CT_MAX (shared columns)


