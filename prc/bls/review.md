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

# Review

- PART_COMP to PARTIAL_CHECKS
- graded color
- split triviality section, move 4 and 7 close to each other
- CT, CT_MAX fill constants and defined CT for EVERY precompile
- CT needs to count for every precompile, both to use an internal counter for constancy and to make IS_INFINITY work correctly
- if we count with CT also along result rows, we do not need anymore the index constancy condition to propagate the triviality case