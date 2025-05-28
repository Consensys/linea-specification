# OOB

- Formatting

# BLS

- Formatting
- Ensure the trivility cases are detected correctly even in the case of a single pair of points. Specifically, we need to take into consideration both if the small point and the large point are at infinity. It would be ideal to fix this before the merge to main or do not include it in the input file.
- Do not compress the ISZERO check by adding the coordinates as the addition will become costly when we change field

- CT as N - 1
- Update note in CT, CT_MAX section
- CT_MAX for result
- CT = INDEX in the case of point evaluation, IS_FIRST_INPUT + IS_SECOND_INPUT still equal to 0
- is_n_inputs_multiple_of_2 rename, we may have 2 shorthands: ct_follows_index and ct_follows_its_own_schedule
- define is_variable_size_data inside ACCP section
- G1MTR,G2... IS_FIRST_INPUT remove from multiplication
- MALFORMED_DATA, MALFORMED_DATA_ACC, MALFORMED_DATA_ACC_MAX instead of NOT_ON...


# 28/5 review

- Split utils wellformed + infinity;