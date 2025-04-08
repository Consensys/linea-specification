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

There is an important distinction between `ECADD` / `ECMUL` / `ECPAIRING` and the new BLS precompiles, starting with `POINT_EVALUATION` and which is true of all other BLS precompiles.
There is no scenario where the data transfer step is skipped.
At this point in time I believe that, given that we will use the same common part of the OOB processing of precompiles for the BLS precompiles, that we can keep the same processing
for all the BLS precompiles as we have for `ECADD` / `ECMUL`:

- if `hub_success ≡ true` then transfer data to the BLS module
    - indeed `hub_success ≡ extract_call_data` for BLS instructions
- if `SUCCESS_BIT ≡ false` then
    - we stop here
- if `SUCCESS_BIT ≡ true` then
    - perform a full copy of the result from `XXX_DATA` module to dedicated RAM segment
- if `SUCCESS_BIT ≡ true` `r@c ≠ 0` then perform a partial result from the dedicated RAM segment module to the caller's RAM
