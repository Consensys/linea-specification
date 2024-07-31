# ECRECOVER

- we compute INTERNAL_CHECKS_PASSED
- this column should be stamp constant (OK)
- the prover "glue" needs to be able to extract the stuff to send to GNARK easily, for this we need to know
  - INTERNAL_CHECKS_PASSED  (computed)
  - SUCCESS_BIT              (prediction propagated from HUB --> MMU --> MMIO --> ECDATA)
  - SEND_TO_GNARK
- in the ECRECOVER case SEND_TO_GNARK ≡ INTERNAL_CHECKS_PASSED

The prover can detect stuff to send to Gnark in our traces using the following selector

CIRCUIT_SELECTOR_ECRECOVER                ≡ INTERNAL_CHECKS_PASSED  *  (IS_ECRECOVER_DATA + IS_ECRECOVER_RESULT)
CIRCUIT_SELECTOR_ECADD                    ≡ INTERNAL_CHECKS_PASSED  *  (IS_ECADD_DATA + IS_ECADD_RESULT)
CIRCUIT_SELECTOR_ECMUL                    ≡ INTERNAL_CHECKS_PASSED  *  (IS_ECMUL_DATA + IS_ECMUL_RESULT)
CIRCUIT_SELECTOR_ECPAIRING                ≡ INTERNAL_CHECKS_PASSED  *  (IS_ECPAIRING_DATA + IS_ECPAIRING_RESULT)  *  (1 - SOMETHING_WASNT_ON_G2)  *  ACCEPTABLE_PAIR_OF_POINTS_FOR_PAIRING_CIRCUIT
                                          ≡ ACCEPTABLE_PAIR_OF_POINTS_FOR_PAIRING_CIRCUIT
CIRCUIT_SELECTOR_ECPAIRING_G2_MEMBERSHIP  ≡ INTERNAL_CHECKS_PASSED  *  (IS_ECPAIRING_DATA + IS_ECPAIRING_RESULT)  *  G2_MEMBERSHIP_TEST_REQUIRED
                                          ≡ G2_MEMBERSHIP_TEST_REQUIRED  (has to be enforced)

stuff to send will always be the same for everything except the membership test ?
- ID
- INDEX
- LIMB
- SUCCESS_BIT

stuff to send for G2_MEMBERSHIP circuit
- ID (refined to allow for several points on G2, may require a new column)
- CT
- LIMB
- THIS_IS_NOT_ON_G2

Test: call ECPAIRING with CHECKS_SUCCEED and several trivial pairs of points on it that will trigger calls to MEMBERSHIP

Question: how do we handle the case where ECPAIRING is given only trivial points ? in the sense of points of the form (P, ∞) ? Where all P are C1 points.

EVERYTHING_TRIVIAL_ACCUMULATOR
- binary
- If INTERNAL_CHECKS_PASSED = 0 Then 0
- monotony condition
- constant along small points
- constant along large points
- inherited at large => small point transitions
- set at small => large point transitions (= 1 iff large point is the point at infinity)

If at transition from data to result EVERYTHING_TRIVIAL_ACCUMULATOR = 1 Then we manually set the result to 0x 00 ... 00 01 (in B_{32})
If IS_ECPAIRING_DATA[i - 1] = 1 and IS_ECPAIRING_RESULT[i] = 1 and EVERYTHING_TRIVIAL_ACCUMULATOR[i - 1] = 1
- SUCCESS_BIT[i] = 1
- LIMB[i]        = 0
- LIMB[i + 1]    = 1

<!-- FULLY_TRIVIAL_PAIRING -->
<!-- - binary column -->
<!-- - stamp constant -->
<!--   - If is_pairing = 0 Then 0 -->
<!--   - If INTERNAL_CHECKS_PASSED = 0 Then 0 -->
<!--   - If SUCCESS_BIT = 0 Then 0 -->
<!--   - If SUCCESS_BIT = 1 Then -->
