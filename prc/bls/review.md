# OOB

- Add shorthand for bls_fixed_size (it seems we would need that only in one spot, is it actually useful?)

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