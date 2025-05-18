# OOB

- Formatting

# BLS

- Formatting
- Ensure the trivility cases are detected correctly even in the case of a single pair of points. Specifically, we need to take into consideration both if the small point and the large point are at infinity. It would be ideal to fix this before the merge to main or do not include it in the input file.
- Do not compress the ISZERO check by adding the coordinates as the addition will become costly when we change field