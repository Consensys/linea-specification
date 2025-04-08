# Notes

## `POINT_EVALUATION` precompile

- [x] OOB change: new OOB_INST_POINT_EVALUATION operation
    - checks for: `sufficient_gas ∧ valid_cds`
    - all the other good stuff (nonzero r@c etc ...)
- [x] HUB change: new precompile execution path
    - new `scenario/POINT_EVALUATION` flag
    - can trigger both `scenario/FAILURE_KNOWN_TO_HUB`, via OOB call, and `scenario/FAILURE_KNOWN_TO_RAM`, via `MMU -> MMIO -> BLS` call
- [ ] BLS module:
    - preliminary module with all the infrastructure in place but that can only deal with `POINT_EVALUATION`
