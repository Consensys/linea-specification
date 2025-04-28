# OOB

- Formatting

# BLS

- Formatting

- We may want to distinguish trivial case:
    - Totally trivial: all points are at infinity. In this case, no circuit is needed.
    - Trivial: one of the two points is always at infinity and the other one belongs to the curve. In this case, we do not need (and cannot use it) the pairing circuit at all but just the membership one.
- Formalize the above carefully in notes.md before writing the actual specs.

- Remove BLS prefix inside BLS module to save space from the rendeding only

22/04

- Ensure the trivility cases are detected correctly even in the case of a single pair of points. Specifically, we need to take into consideration both if the small point and the large point are at infinity.