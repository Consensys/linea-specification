
## TODO

- global icf, icp definitions
- double check constancies
- check if we still need ACCPC or PAIR_OF_POINTS_CONTAINS_INFINITY is enough
- Fix interface
- Double check definitions of C/G 1,2 MTR columns and update corresponding section
- MALFORMED_DATA_INTERNAL_JUSTIFICATION + MALFORMED_DATA_EXTERNAL_JUSTIFICATION + WELLFORMED_DATA_TRIVIAL + WELLFORMED_DATA_NONTRIVIAL = 1 makes sense only for pairings. For the others, we can have only MALFORMED_DATA_INTERNAL_JUSTIFICATION + MALFORMED_DATA_EXTERNAL_JUSTIFICATION being equal to 1, but they can also be both 0. 

## Pairing logic

wellformed_data ≡ + WELLFORMED_DATA_TRIVIAL
                  + WELLFORMED_DATA_NONTRIVIAL

malformed_data ≡ + MALFORMED_DATA_INTERNAL_JUSTIFICATION
                 + MALFORMED_DATA_EXTERNAL_JUSTIFICATION

MALFORMED_DATA     ⇒ MALFORMED_DATA_BIT
MALFORMED_DATA_ACC ⇒ MALFORMED_DATA_ACC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                    ;;
;; There is a standing hypothesis: IS_BLS_PAIRING = 1 ;;
;;                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

We add another column that is pair-of-points constant called
- PAIR_OF_POINTS_CONTAINS_INFINITY:
    - boolean column
    - pair-of-point-constant
    - If IS_BLS_PAIRING_DATA = 0     Then it's ≡ 0
    - If icf = 1  Then it's ≡ 0
    - If MALFORMED_DATA_EXTERNAL_JUSTIFICATION = 1               Then it's ≡ 0
    - If WELLFORMED_DATA_TRIVIAL ∨ WELLFORMED_DATA_NONTRIVIAL ≡ true Then we set its value at the transition from small to large point
        - small_point_is_infinity ≡ IS_INFINITY[i]
        - large_point_is_infinity ≡ IS_INFINITY[i + 1]
        - you set its value when transitioning from small point to large point:
        - PAIR_OF_POINTS_CONTAINS_INFINITY = small_point_is_infinity ∨ large_point_is_infinity
                                           = small_point_is_infinity + large_point_is_infinity - small_point_is_infinity ∙ large_point_is_infinity

we talk exclusively about BLS_PAIRING
we introduce the following columns / shorthands

- icf ≡ MALFORMED_DATA_INTERNAL_JUSTIFICATION: `internal_checks_failed` shorthand; data is malformed and we can check in module
- MALFORMED_DATA_EXTERNAL_JUSTIFICATION: data is malformed but we cannot see it locally (and recognized as such by gnark)
- TRIVIAL: data is not malformed in any way but every pair of points is either
    - (∞, ∞)
    - (P, ∞)
    - (∞, Q)
- NONTRIVIAL: data is not malformed in any way and there exists at least one pair of points of the form
    - (P, Q)

We will still require a TRIVIAL_ACC column
- it is counter-constant
- you set it at transition points (when entering IS_SMALL / IS_LARGE) using IS_INFINITY
- when transitioning from data to result you use it to set WELLFORMED_DATA_TRIVIAL / NONTRIVIAL
    - we are basically justifying predictions:
    - If WELLFORMED_DATA_TRIVIAL    = 1 Then TRIVIAL_ACC = 1
    - If WELLFORMED_DATA_NONTRIVIAL = 1 Then TRIVIAL_ACC = 0

They are
- binary
- ID or INDEX-constant (tbd) (probably ID-constant)
- we ask that
    MALFORMED_DATA_INTERNAL_JUSTIFICATION + MALFORMED_DATA_EXTERNAL_JUSTIFICATION + WELLFORMED_DATA_TRIVIAL + WELLFORMED_DATA_NONTRIVIAL = flag_sum

TODO: 
- WELLFORMED_DATA_NONTRIVIAL, in the case of precompieles other than pairings, menas data are wellformed and the TRIVIAL case must be 0 as it is not relevant.
- POINTEVALUATION can be malformed and justified internally completely;
- All the others can be malformed both internally and externally;

Concerning MALFORMED_DATA_EXTERNAL_JUSTIFICATION:
- MALFORMED_DATA     binary counter-constant
- MALFORMED_DATA_ACC binary counter-constant
- the logic for MALFORMED_DATA_BIT, MALFORMED_DATA_ACC and MALFORMED_DATA_EXTERNAL_JUSTIFICATION(_ACC_MAX) is the same as before
- you set MALFORMED_DATA_ACC = MALFORMED_DATA_BIT at the start (entering data for the first time)
- at transition from small to large or large to small
    - If   IS_SMALL[i] ∙ IS_LARGE[i + 1] + IS_LARGE[i] ∙ IS_SMALL[i + 1] = 1
    - Then MALFORMED_DATA_ACC[i + 1] = MALFORMED_DATA_ACC[i] + MALFORMED_DATA_BIT[i + 1]
- at transition from large to small:
- if MALFORMED_DATA_ACC = 1 then
- We will impose MALFORMED_DATA_BIT = 0 whenever
    - MALFORMED_DATA_INTERNAL_JUSTIFICATION = 0
    - is_result = 1
if follows that MALFORMED_DATA_ACC and MALFORMED_DATA_EXTERNAL_JUSTIFICATION are zero.

Note. MALFORMED_DATA is counter-constant and pertains to a single (small or large) point.

If MALFORMED_DATA_EXTERNAL_JUSTIFICATION ≡ true then we only require that MALFORMED_DATA = 1 along a small or large point where IS_INFINITY ≡ false.


## Circuit selectors

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                    ;;
;; There is a standing hypothesis: IS_BLS_PAIRING = 1 ;;
;;                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


- CIRCUIT_SELECTOR_G1_MEMBERSHIP_TEST (CSG1MT)
    - malformed  data case: g1cs_for_pairing___malformed  ≡ MALFORMED_DATA_BIT ∙ IS_FIRST_INPUT
    - wellformed data case: g1cs_for_pairing___wellformed ≡ wellformed_data    ∙ IS_FIRST_INPUT ∙ (1 - IS_INFINITY) ∙ PAIR_OF_POINTS_CONTAINS_INFINITY
    - i.e.
        CIRCUIT_SELECTOR_G1_MEMBERSHIP_TEST___for_pairing ≡ + g1cs_for_pairing___malformed
                                                            + g1cs_for_pairing___wellformed

- CIRCUIT_SELECTOR_G2_MEMBERSHIP_TEST (CSG2MT)
    - malformed  data case: g2cs_for_pairing___malformed  ≡ MALFORMED_DATA_BIT ∙ IS_SECOND_INPUT
    - wellformed data case: g2cs_for_pairing___wellformed ≡ wellformed_data    ∙ IS_SECOND_INPUT ∙ (1 - IS_INFINITY) ∙ PAIR_OF_POINTS_CONTAINS_INFINITY
    - i.e.
        CIRCUIT_SELECTOR_G2_MEMBERSHIP_TEST___for_pairing ≡ + g2cs_for_pairing___malformed
                                                            + g2cs_for_pairing___wellformed

- CIRCUIT_SELECTOR_PAIRING
    - wellformed data case:
        CIRCUIT_SELECTOR_PAIRING ≡ WELLFORMED_DATA_NONTRIVIAL ∙ (1 - PAIR_OF_POINTS_CONTAINS_INFINITY)


Note. You will have a constraint à la

CIRCUIT_SELECTOR_G1_MEMBERSHIP_TEST ≡ + IS_BLS_PAIRING_DATA ∙ CIRCUIT_SELECTOR_G1_MEMBERSHIP_TEST___for_pairing
                                      + IS_BLS_G1MSM_DATA   ∙ CIRCUIT_SELECTOR_G1_MEMBERSHIP_TEST___for_g1msm

CIRCUIT_SELECTOR_G2_MEMBERSHIP_TEST ≡ + IS_BLS_PAIRING_DATA ∙ CIRCUIT_SELECTOR_G2_MEMBERSHIP_TEST___for_pairing
                                      + IS_BLS_G2MSM_DATA   ∙ CIRCUIT_SELECTOR_G2_MEMBERSHIP_TEST___for_g2msm

sections on
- malformed stuff (former ICP)
    MALFORMED_DATA_INTERNAL_JUSTIFICATION
- malformed stuff (totally generic)
    MALFORMED_DATA_BIT
    MALFORMED_DATA_ACC
    MALFORMED_DATA_EXTERNAL_JUSTIFICATION


## Macros to remove

internalChecksPassed
trivialAllInf
trivialWithMembershipCheck
notOnCX
notOnCXAcc
notOnCXAccMax
notOnGX
notOnGXAcc
notOnGXAccMax

- This can probably die: acceptablePairOfPoints

## Macros added

malformedDataInternalJustification
trivialAcc
wellformedDataTrivial
wellformedDataNonTrivial
pairOfPointsContainsInfinity
malformedDataBit
malformedDataAcc
malformedDataExternalJustification

Consider keeping ICP and adding:

ICP + MALFORMED_DATA_INTERNAL_JUSTIFICATION = 1

or 

icp_i = 1 - MALFORMED_DATA_INTERNAL_JUSTIFICATION_i


## TODO

- Refine behaviour of MALFORMED_DATA_EXTERNAL_JUSTIFICATION in the case of ADD and MSM. Treat it uniformly.

- Only if the internal checks succeed, we start caring about external checks and so on.
- Rename MALFORMED_DATA_(EXTERNAL_)BIT, MALFORMED_DATA_(EXTERNAL_)ACC  
- Look at the conversation with Olivier.

- Find out if the specification for C/G 1,2 MTR columns fully defines also the corresponding selectors that are relevant for ADD, MSM and PAIRING

