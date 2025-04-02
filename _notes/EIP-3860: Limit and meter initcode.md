# Notes

Impacted modules
- [ ] TXN_DATA
    - [x] verify that a transaction's `INIT_CODE_SIZE` is `≤ 49152 ≡ 2 * MAX_CODE_SIZE`
    - [x] extra ceiling computation for deployments + affects tx cost
- [x] OOB
    - [x] [OOB_INST_XCREATE] / OOB_INST_XCREATE_FLAG / CT_MAX_XCREATE
        - [x] comparison of `init_code_size` to `2 * MAX_CODE_SIZE`
        - [x] imposes that `init_code_size > 2 * MAX_CODE_SIZE` i.e. that `MAXCSX` is active
    - [x] [OOB_INST_CREATE]
        - [x] extra `OOB_DATA_10` column
        - [x] extra `init_code_size ≡ init_code_size_lo` parameter
        - [x] imposes that `init_code_size ≤ 2 * MAX_CODE_SIZE` i.e. that `MAXCSX` is active
- [ ] MXP (no spec change)
    - [ ] modify G_WORD constants
        - CREATE:  0               →                   G_initcodeword
        - CREATE2: G_keccak256word → G_keccak256word + G_initcodeword
- [ ] HUB
    - [ ] acceptable exceptions of CREATE instruction family
        - will we require a new MISC row ? purely for the OOB instruction ?
    - [x] only RETURN and CREATE(2) may trigger `MAXCSX`
    - [ ] interface with MXP

Here's how to deal with the new `OOB_INST_XCREATE` instruction least disruptively:
- we will require that `OOB_INST_XCREATE` be called upon ⇔ stack/MAXCSX = 1
- we add an OOB_DATA_10 column
- the normal OOB_CREATE instruction adds an extra check which is `init_code_size ≤ 49152`
- there is no need to pass the result bit back
