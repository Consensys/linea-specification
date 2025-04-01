# Notes

Impacted modules
- [ ] TXN_DATA
    - [ ] verify that a transaction's `INIT_CODE_SIZE` is `≤ 49152 ≡ 2 * MAX_CODE_SIZE`
    - [ ] extra ceiling computation for deployments + affects tx cost
- [x] OOB
    - [x] comparison of `init_code_size` to `2 * MAX_CODE_SIZE`
    - [x] justifies `MAXCSX` prediction
    - [x] [OOB_INST_XCREATE] / OOB_INST_XCREATE_FLAG / CT_MAX_XCREATE
- [ ] MXP (no spec change)
    - [ ] modify G_WORD constants
        - CREATE:  0               →                   G_initcodeword
        - CREATE2: G_keccak256word → G_keccak256word + G_initcodeword
- [ ] HUB
    - [ ] acceptable exceptions of CREATE instruction family
        - will we require a new MISC row ? purely for the OOB instruction ?
    - [ ] only RETURN and CREATE(2) may trigger `MAXCSX`
    - [ ] interface with MXP
