# OOB

- Formatting

# BLS

- Formatting
- We want to distinguish trivial case:
    - Totally trivial: all points are at infinity. In this case, no circuit is needed.
    - Trivial: one of the two points is always at infinity and the other one belongs to the curve. In this case, we do not need (and cannot use it) the pairing circuit at all but just the membership one.
- Ensure the trivility cases are detected correctly even in the case of a single pair of points. Specifically, we need to take into consideration both if the small point and the large point are at infinity. It would be ideal to fix this before the merge to main or do not include it in the input file.

- Remove BLS prefix inside BLS module to save space from the rendeding only

- Considering using markdown tables (tablemode for vim)

- Do not compress the ISZERO check by adding the coordinates as the addition will become costly when we change field
- Check with BESU team or execution specs to understand if we need some check over the scalar for MSM. Actually, no check is needed, write a note in the specs maybe.