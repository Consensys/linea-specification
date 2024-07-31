ECPAIRING requires detecting the points at infinity
- small point is the poitn at infinity
  - this never matters
- large point is the point at infinity
  - 
- small = (0, 0), large is not the point at infinity  <==  should go to a dedicated G2-membership circuit


When do we need gnark for pairings ?
- the stuff below assumes that the preliminary checks passed
- some point was not on G2
  - single call to the "G2-membership circuit" with MEMBERSHIP_BIT = 0
- all large points are on G2; this determines two different calls to Gnark:
  - (∞, ∞): this point will be ignored (it's well formed and its contribution to the pairing is nil)
  - (P, ∞): this point will be ignored (it's well formed and its contribution to the pairing is nil)
  - (∞, Q) with Q ≠ ∞: we must send Q to the "G2-membership circuit" with MEMBERSHIP_BIT = 1
  - (P, Q) with P ≠ ∞ and Q ≠ ∞: we must send all of these points to Gnark in the pairing
- we probably need the following columns:
  - G2_MEMBERSHIP_TEST_REQUIRED                   ≡ G2MTR
  - ACCEPTABLE_PAIR_OF_POINTS_FOR_PAIRING_CIRCUIT ≡ ACCPC


ACCPC ≡ constant along the 4 + 8 = 12 rows of a pair of points
G2MTR ≡ constant along the     8      rows containing a supposed G2 point and zero along C1 points

G2_MEMBERSHIP_BIT ≡ 0 if G2MTR ≡ false


SOMETHING_WASNT_ON_G2 ≡ false
=============================

| Pair of points | G2_MEMBERSHIP_BIT | G2MTR | ACCPC | Gnark circuit                               |
|----------------+-------------------+-------+-------+---------------------------------------------|
| (∞, ∞)         | none required     | 0     | 0     |                                             |
| (P, ∞)         | none required     | 0     | 0     |                                             |
| (∞, Q)         | 1                 | 1     | 0     | G2-membership-circuit                       |
| (P, Q)         | none required     | 0     | 1     | Pairing-circuit  (implicit membership test) |


SOMETHING_WASNT_ON_G2 ≡ true
============================

The ECDATA module predicts that some Q isn't on G2,
we (nondeterministically) select one of these points
among all those given in the pairing data and 

| Pair of points | MEMBERSHIP_BIT | G2MTR | ACCPC | Gnark circuit         |
|----------------+----------------+-------+-------+-----------------------|
| (∞, Q)         | 0              | 1     | 0     | G2-membership-circuit |
| (P, Q)         | 0              | 1     | 0     | G2-membership-circuit |


INTERNAL tests are the first hurdle.
Then there are two cases:

- SOMETHING_WASNT_ON_G2 = true
  - we nondeterministically select one of the supposed G2 points that isn't part of G2 and send it to the G2-membership-circuit with a MEMBERSHIP_BIT = false
- SOMETHING_WASNT_ON_G2 = false
  - every nontrivial pair of points has to go somewhere
    - trivial pairs are of the form (P, ∞)
    - nontrivial is everything else
    - see row 3 and 4 of the first table
  - we nondeterministically select one of the supposed G2 points that isn't part of G2 and send it to the G2-membership-circuit with a MEMBERSHIP_BIT = false
