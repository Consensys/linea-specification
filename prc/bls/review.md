# OOB

- Binary constraints rendering
- call to bls ref table: rename "precompile" and "number"
- Add bls precompiles to list of commons
- Add shorthand for bls_fixed_size
- Remove i from bls shorthands fixed_cds, ..., msm_multiplication_cost
- fixed size fixed cost define precompile cost as equal to fixed gas cost...
- Shift back indexes of bls pairing
- Formatting for bls pairing (use array like in the case of flag_sum_inst...)

# BLS
- Trivial case BLS pairing is different wrt ECDATA pairing
- NOT_ON_CURVE, NOT_ON_CURVE_ACC, NOT_ON_CURVE_ACC_MAX, NOT_ON_SUBROUP, NOT_ON_SUBGROUP_ACC, NOT_ON_SUBGROUP_ACC_MAX and use IS_FIRST_INPUT and IS_SECOND_INPUT to differentiate
- We may want to distinguish trivial case:
    - Totally trivial: all points are at infinity. In this case, no circuit is needed.
    - Trivial: one of the two points is always at infinity and the other one belongs to the curve. In this case, we do not need (and cannot use it) the pairing circuit at all but just the membership one.
- Align to left shorthands (RESULT, DATA emphasized as the only different part)
- Formatting...
- Array for ... = IS_FIRST_INPUT + IS_SECOND_INPUT constraint in CT, CT_MAX ... section
- Remove BLS prefix inside BLS module to save space from the rendeding only
- $\isBlsGOneMsmData_{i} + \isBlsGTwoMsmData_{i} + \isBlsPairingCheckData_{i} = 0$ make shorthand for this
- ACC_INPUTS merge last 3 constraints after introducing shorthand in the same section