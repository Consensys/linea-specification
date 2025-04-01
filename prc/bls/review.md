# OOB

- Add shorthand for bls_fixed_size (it seems we would need that only in one spot, is it actually useful?)
- Formatting

# BLS

- Formatting

- Trivial case BLS pairing is different wrt ECDATA pairing
- NOT_ON_CURVE, NOT_ON_CURVE_ACC, NOT_ON_CURVE_ACC_MAX, NOT_ON_SUBROUP, NOT_ON_SUBGROUP_ACC, NOT_ON_SUBGROUP_ACC_MAX and use IS_FIRST_INPUT and IS_SECOND_INPUT to differentiate
- We may want to distinguish trivial case:
    - Totally trivial: all points are at infinity. In this case, no circuit is needed.
    - Trivial: one of the two points is always at infinity and the other one belongs to the curve. In this case, we do not need (and cannot use it) the pairing circuit at all but just the membership one.
- Formalize the above carefully in notes.md before writing the actual specs.

- Remove BLS prefix inside BLS module to save space from the rendeding only
