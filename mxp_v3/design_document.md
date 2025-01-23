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

In all cases we want:
MACRO (1 row) ==> INSTRUCTION_DECODER (1 row) ==> SCENARIO (1 row) ==> COMPUTATION (1 + CT_MAX rows)

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

ID ← duplicate the INST value and instruction decode the ID columns (1 row, 14 columns)
    - decoder/INST
    - decoder/IS_WORD_PRICING
    - decoder/IS_BYTE_PRICING
    - decoder/IS_MSIZE
    - decoder/IS_FIXED_SIZE_32  // have to be added; their purpose is simply to enforce the SIZE_1 values for these instructions (though the HUB will already do this)
    - decoder/IS_FIXED_SIZE_1   // have to be added; their purpose is simply to enforce the SIZE_1 values for these instructions (though the HUB will already do this)
    - decoder/IS_RETURN
    - decoder/IS_REVERT (?)
    - decoder/IS_CALL
    - decoder/SINGLE_MAX_OFFSET_COMPUTATION_REQUIRED
    - decoder/DOUBLE_MAX_OFFSET_COMPUTATION_REQUIRED
    - decoder/G_WORD
    - decoder/G_BYTE

MACRO (1 row, 16 columns)
    - macro/INST
    - macro/OFFSET_1/2_HI/LO
    - macro/SIZE_1/2_HI/LO
    - macro/DEPLOYING
    - macro/RES <- where we will write the ouput of MSIZE
    - macro/MXPX
    - macro/GAS_MXP
    - macro/MAY_TRIGGER_NONTRIVIAL_MMU_OPERATION
    - macro/S1NZNOMXPX
    - macro/S2NZNOMXPX

SCENARIO  (1 row) (to distinguish between the 6 possible scenarios)
    - scenario/TRIVIAL_OPERATION
        - for all variable size OPCODES in case their SIZE arguement(s) are (both) zero
    - scenario/MEMORY_EXPANSION_EXCEPTION
        - the following two computations will take place in all cases, if one of them returns `true` then we trigger scenario/MEMORY_EXPANSION_EXCEPTION, otherwise we trigger the other stuff
            - one of the SIZE's is nonzero and the corresponding OFFSET is huge
            - one of the SIZE's is huge
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
    - we further use the scenario row to store data; also the consistency arguments will apply to this
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

The actual computations that will take place:
- perform the zeroness checks for SIZE's
    - this will justify the value of scenario/TRIVIAL_OPERATION
- perform the out of bounds checks
    - smallness checks for SIZE's
    - smallness checks for OFFSET's
    - this will justify the value of
        - scenario/MEMORY_EXPANSION_EXCEPTION
        - macro/MXPX
- determination of MAX_OFFSET (2 cases: SINGLE/DOUBLE) (will always happen, but different number of rows depending on case)
- S[1/2]NZOP ... (will always happen, but different number of rows depending on case)
- quadratic cost
    - we will want some parametrized (row offset + values that enter the computation)
- linear cost (2 cases: BYTE_PRICING / WORD_PRICING)
    - we will want some parametrized constraint system for both (row offset + values that enter the computation)

CT
CT_MAX (shared columns)
CONTEXT_NUMBER
MXP_STAMP

TODOs:
- update the lookup from the HUB into the MXP module


