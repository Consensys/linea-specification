# EIP-2537: Precompile for BLS12-381 curve operations  
Adds operation on BLS12-381 curve as a precompile in a set necessary to efficiently perform operations such as BLS signature verification.

Reference: https://eips.ethereum.org/EIPS/eip-2537

## List of precompiles

| Precompile              | Addresss |
|-------------------------|----------|
| BLS12_G1ADD             | 0x0b     |
| BLS12_G1MSM             | 0x0c     |
| BLS12_G2ADD             | 0x0d     |
| BLS12_G2MSM             | 0x0e     |
| BLS12_PAIRING_CHECK     | 0x0f     |
| BLS12_MAP_FP_TO_G1      | 0x10     |
| BLS12_MAP_FP2_TO_G2     | 0x11     |

## Key curve parameters

```
Base field modulus = p = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab
Fp - finite field of size p
Curve Fp equation: Y^2 = X^3+B (mod p)

Fp quadratic non-residue = nr2 = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaaa
Fp2 is Fp[X]/(X^2-nr2)
Curve Fp2 equation: Y^2 = X^3 + B*(v+1) where v is the square root of nr2
```

Note that in the $\mathbb{F}_{p^2}$ coordinates, both of them (imaginary and real part) has to be smaller than $p$.

## Points

```
Each coordinate is represented using 64 bytes, where the first 16 bytes are supposed to be 0s and the remaining 48 bytes represent the actual value:

small point (point supposed to be on G1):

(Ax, Ay)

large point (point supposed to be on G2):

(BxIm, BxRe, ByIm, ByRe)

Thus, each requires 4 half ewords:

e.g.,

From most significant limb to least significant limb:

Ax_3, Ax_2, Ax_1, Ax_0

```

## Operations performed by the arithmetization

- TRM:
    - Recognize which precompile we are dealing with.
- OOB:
    - Input length check, i.e., the call data size is equal or multiple of an expected number. 
    - Gas check, i.e., enough gas is provided.
- BLS:
    - Coordinate encoding check, specifically whether a small point coordinate belongs to $\mathbb{F}_p$ or a large point coordinate belongs to $\mathbb{F}_{p^2}$ ($< p$ for every coordinate).
    - Point at infinity check.
    - By potentially interacting with external circuits, justifying the success bit of the operation.

## Operations performed by external circuits

Let $\mathbb{G}_1$ be $\mathbb{C}_1$ subgroup and $\mathbb{G}_2$ be $\mathbb{C}_2$ subgroup.

- $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership check.
- $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership check.
- The actual precompiles computation.

## Checks overview

- BLS12_G1ADD,  $\mathbb{C_1} \times \mathbb{C_1}$ (256 bytes) $\rightarrow \mathbb{C_1}$ (128 bytes)
    - OOB:
        - input length: 
            ```
            PRC_BLS12_G1ADD_SIZE = 256
            ```
        - gas check:    
            ```
            GAS_CONST_BLS12_G1_ADD = 375 
            ```
    - BLS
        - coordinate encoding
        - points at infinity
        - $\mathbb{C}_1$ mermbership         
- BLS12_G1MSM, $(\mathbb{G_1} \times \mathbb{N})^k$ ($160 (128 + 32) \cdot k$ bytes) $\rightarrow \mathbb{G_1}$ (128 bytes) with $k > 0$
     - OOB:
        - input length: 
            ```
            k > 0 (cds != 0)
            k <= 128 or k > 128 (to determine PRC_BLS12_G1MSM_DISCOUNT(k))
            PRC_BLS12_G1MSM_SIZE = 160
            PRC_BLS12_G1MSM_SIZE * k
            ```
        - gas check:
            ```
            PRC_BLS12_G1MSM_MULTIPLICATION_COST = 12000
            PRC_BLS12_G1MSM_MULTIPLIER = 1000
            PRC_BLS12_G1MSM_MAX_DISCOUNT = 519
            k = floor(len(input) / PRC_BLS12_G1MSM_SIZE);
            if k == 0 {
                gas_cost = 0
            }
            PRC_BLS12_G1MSM_DISCOUNT(k) = see BLS_REFTABLE if 1 <= k <= 128
            PRC_BLS12_G1MSM_DISCOUNT(k) = PRC_BLS12_G1MSM_MAX_DISCOUNT if k > 128
            gas_cost = k * PRC_BLS12_G1MSM_MULTIPLICATION_COST * PRC_BLS12_G1MSM_DISCOUNT(k) // PRC_BLS12_G1MSM_MULTIPLIER;
            where // is integer division
            ```
            We use floor division to get the number of pairs. If the length of the input is not divisible by `PRC_BLS12_G1MSM_SIZE` we still produce some result, but later on the precompile will return an error. Also, the case when $k = 0$ will make hub_success = 0 (see OOB). In any case, the main precompile routine must produce an error on such an input because it violated encoding rules. This holds also for BLS12_G2MSM.
    - BLS
        - coordinate encoding
        - point at infinity
        - $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership        
- BLS12_G2ADD $\mathbb{C_2} \times \mathbb{C_2}$ (512 bytes) $\rightarrow \mathbb{C_2}$ (256 bytes)
    - OOB:
        - input length: 
            ```
            PRC_BLS12_G2ADD_SIZE = 512
            ```
        - gas check:
            ```
            GAS_CONST_BLS12_G2_ADD = 600
            ```
    - BLS
        - coordinate encoding
        - points at infinity
        - $\mathbb{C}_2$ mermbership              
- BLS12_G2MSM $(\mathbb{G_2} \times \mathbb{N})^k$ ($288 (256 + 32) \cdot k$ bytes) $\rightarrow \mathbb{G_2}$ (256 bytes) with $k > 0$     
    - OOB:
        - input length: $288 \cdot k$ bytes
            ```
            k > 0 (cds != 0)
            k <= 128 or k > 128 (to determine PRC_BLS12_G2MSM_DISCOUNT(k))
            PRC_BLS12_G2MSM_SIZE = 288
            PRC_BLS12_G2MSM_SIZE * k
            ```
        - gas check:
            ```
            PRC_BLS12_G2MSM_MULTIPLICATION_COST = 22500
            PRC_BLS12_G2MSM_MULTIPLIER = 1000
            PRC_BLS12_G2MSM_MAX_DISCOUNT = 524
            k = floor(len(input) / PRC_BLS12_G2MSM_SIZE);
            if k == 0 {
                gas_cost = 0
            }
            PRC_BLS12_G2MSM_DISCOUNT(k) = see BLS_REFTABLE if 1 <= k <= 128
            PRC_BLS12_G2MSM_DISCOUNT(k) = PRC_BLS12_G2MSM_MAX_DISCOUNT if k > 128
            gas_cost = k * PRC_BLS12_G2MSM_MULTIPLICATION_COST * PRC_BLS12_G2MSM_DISCOUNT(k) // PRC_BLS12_G2MSM_MULTIPLIER;
            where // is integer division
            ```
    - BLS
        - coordinate encoding
        - point at infinity
        - $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership 
- BLS12_PAIRING_CHECK $(\mathbb{G_1} \times \mathbb{G_2})^k$ ($384 \cdot k$ bytes) $\rightarrow \{0,1\}$ (right padded to 32 bytes) with $k > 0$    
    - OOB:
        - input length: 
            ```
            k > 0 (cds != 0)
            PRC_BLS12_BLS12_PAIRING_CHECK_SIZE = 384
            PRC_BLS12_BLS12_PAIRING_CHECK_SIZE * k
            ```
        - gas check:
            ```
            PRC_BLS12_BLS12_PAIRING_CHECK_SIZE = 384
            k = floor(len(input) / PRC_BLS12_BLS12_PAIRING_CHECK_SIZE);
            GAS_CONST_BLS12_PAIRING = 37700
            GAS_CONST_BLS12_PAIRING_CHECK_PAIR = 32600
            gas_cost = GAS_CONST_BLS12_PAIRING_CHECK_PAIR*k + GAS_CONST_BLS12_PAIRING_CHECK;
            ```
            We use floor division to get the number of pairs. If the length of the input is not divisible by `PRC_BLS12_BLS12_PAIRING_CHECK_SIZE` we still produce some result, but later on the precompile will return an error (the precompile routine must produce an error on such an input because it violated encoding rules).
            We want both the input length and gas check being performed in the same OOB operation. Moreover, we want to follow the same approach of OOB_INST_ECPAIRING in case cds is not a multiple of 384 bytes, that is the return_gas = 0 (all of it is consumed).
    - BLS
        - coordinate encoding
        - point at infinity
        - $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership   
        - $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership 
- BLS12_MAP_FP_TO_G1 $\mathbb{F}_p$ (64 bytes) $\rightarrow \mathbb{G_1}$ (128 bytes)
    - OOB:
        - input length:
            ```
            PRC_BLS12_MAP_FP_TO_G1_SIZE = 64
            ```
        - gas check:
            ```
            GAS_CONST_BLS12_MAP_FP_TO_G1 = 5500
            ```
    - BLS
        - coordinate encoding
- BLS12_MAP_FP2_TO_G2 $\mathbb{F}_{p^2}$ (128 bytes) $\rightarrow \mathbb{G_2}$ (256 bytes)
    - OOB:
        - input length:
            ```
            PRC_BLS_MAP_FP2_TO_G2_SIZE = 128
            ```
        - gas check: 
            ```
            GAS_CONST_BLS_MAP_FP2_TO_G2 = 23800
            ```
    - BLS
        - coordinate encoding

- POINT_EVALUATION (192 bytes) $\rightarrow$ (64 bytes)
    - OOB:
        - input length:
            ```
            PRC_POINT_EVALUATION_SIZE = 192
            ```
        - gas check: 
            ```
            GAS_CONST_POINT_EVALUATION = 50000
            ```
    - BLS
        - coordinate encoding, which in this case means:
        ```
        z, y < BLS_PRIME
        where BLS_PRIME = 73EDA753299D7D483339D80809A1D80553BDA402FFFE5BFEFFFFFFFF00000001
        ```


Note that addition operations do not require subgroup membership checks. 
In case the operations are executed on points not in the subgroup, also the result will not be in the subgroup.
A user who wants addition and subgroup membership check can use $MSM((P,1),(Q,1))=P \times 1 + Q \times 1 = P + Q$ since MSM precompile does subgroup membership check.

## Modules

Beyond creating an new BLS module (and BLS_REFTABLE), the following existing modules will be affected:

- HUB:  precompile processing.
- OOB:  for detecting `FAILURE_KNOWN_TO_HUB`, specifically checking if the call data size is acceptable and if enough gas is provided. If input is 0 also, the HUB needs to know it and we do not trigger RAM and BLS at all.
- TRM:  for updating the range check that justifies the `IS_PRECOMPILE` flag, that is identifying which precompile we are dealing with.
- MMIO: for lookup to new BLS module.

```
HUB  - is it a precomopile?           -> TRM

HUB  - cds is valid? gas is enough?   -> OOB

If necessary:
OOB  - discount for MSM?              -> BLS_REFTABLE

If it makes sense:
HUB  -                                -> MMU  

MMU  -                                -> MMIO

If it makes sense:
MMIO -                                -> BLS
```

MMIO to BLS lookup:
- ID
- LIMB
- INDEX
- INDEX_MAX / SIZE
- SUCCESS_BIT

@TODO: look at ECDATA as a reference.

## Comparisons

All comparisons will require two interactions with WCP (48 byte data):

```

wcpGeneralizedCallToLT(A_3, A_2, A_1, A_0, B_3, B_2, B_1, B_0)

<=>

wcpCallToLT(A_3, A_2, B_3, B_2)

∨

(wcpCallToEQ(A_3, A_2, B_3, B_2) ∧ wcpCallToLT(A_1, A_0, B_1, B_0))

```

Note that in practice $B$ will likely always be $p$

## External circuit interface

- C1_MEMBERSHIP
- G1_MEMBERSHIP
- C2_MEMBERSHIP
- G2_MEMBERSHIP
- PAIRING
- G1_ADD
- G2_ADD
- G1_MSM
- G2_MSM
- MAP_FP_TO_G1
- MAP_FP2_TO_G2
- POINT_EVALUATION

### Failure case (assuming ICP = 1 but NOT_ON_G1_ACC_MAX = 0 or NOT_ON_G2_ACC_MAX = 0 and SUCCESS_BIT = 0)

- BLS12_G1ADD: send to C1_MEMBERSHIP circuit the point predicted not to be in C1, so as to prove non-membership.            
- BLS12_G1MSM: 
Based on the predictions related to a point being in C1 or G1, the following cases are possible:

| ON_C1 | ON_G1 | Send to       |
|-------|-------|---------------|
|     0 |     0 | C1_MEMBERSHIP | 
|     0 |     1 | C1_MEMBERSHIP |
|     1 |     0 | G1_MEMBERSHIP |

so as to prove non-membership. Note that in the first case we prove C1 non-membership as it is cheaper than G1 non-membership, and that is enough to justify failure.
- BLS12_G2ADD: send to C2_MEMBERSHIP circuit the point predicted not to be in C2, so as to prove non-membership.           
- BLS12_G2MSM:
Based on the predictions related to a point being in C2 or G2, the following cases are possible:

| ON_C2 | ON_G2 | Send to       |
|-------|-------|---------------|
|     0 |     0 | C2_MEMBERSHIP | 
|     0 |     1 | C2_MEMBERSHIP |
|     1 |     0 | G2_MEMBERSHIP |

so as to prove non-membership. Note that in the first case we prove C2 non-membership as it is cheaper than G2 non-membership, and that is enough to justify failure.
- BLS12_MAP_FP_TO_G1: no circuit needed.
- BLS12_MAP_FP2_TO_G2: no circuit needed.
- POINT_EVALUATION: no circuit needed.

### Success case (assuming ICP = 1 and NOT_ON_C1_ACC_MAX = NOT_ON_C2_ACC_MAX = NOT_ON_G1_ACC_MAX = NOT_ON_G2_ACC_MAX = 0 and SUCCESS_BIT = 1)

- BLS12_G1ADD: send points to G1_ADD circuit (C1 membership is included).
- BLS12_G1MSM: send points to G1_MSM circuit (C1 and G1 memberships are included). 
- BLS12_G2ADD: send points to G2_ADD circuit (C2 membership is included).
- BLS12_G2MSM: send points to G2_MSM circuit (C2 and G2 memberships are included). 
- BLS12_PAIRING_CHECK: 
    - TRIVIAL_ALL_INFTY case: If all small and large point are at infinity, do nothing.
    - TRIVIAL_WITH_MEMBERSHIP_CHECK case: If for every pair of points, one is at infinity and the other is not, then:
        - If small point is at infinity, then send large point to G2_MEMBERSHIP circuit to prove membership to C2 and G2.
        - If large point is at infinity, then send small point to G1_MEMBERSHIP circuit to prove membership to C1 and G1.
    - non_trivial case: If there is at least one pair points that are not at infinity, then:
        - If small point is at infinity, then send large point to G2_MEMBERSHIP circuit to prove membership to C2 and G2.
        - If large point is at infinity, then send small point to G1_MEMBERSHIP circuit to prove membership to C1 and G1.
        - If pair of point is non-trivial (neither the small point nor the large are at infinity), send the pair to the PAIRING circuit. 
- BLS12_MAP_FP_TO_G1: send field element to MAP_FP_TO_G1 circuit.
- BLS12_MAP_FP2_TO_G2: send field element to MAP_FP2_TO_G2 circuit.
- POINT_EVALUATION: send input to POINT_EVALUATION circuit.

## Properties of circuits

- Proving C1 and C2 membership or non-membership is cheaper than proving G1 and G2 membership or non-membership, respectively.
- G1_ADD circuit includes C1 membership check.
- G1_MSM circuit includes C1 and G1 membership check.
- G2_ADD circuit includes C2 membership check.
- G2_MSM circuit includes C2 and G2 membership check.
- PAIRING circuit accepts only non-trivial pair of points.
- Points at infinity must be detected on the arithmetization side and never be sent to the pairing circut, but they can be sent to any other.

- GX_MEMBERSHIP_TEST = 1 means the point belongs to both GX and CX.
- GX_MEMBERSHIP_TEST = 0 means the point does not belong to GX. Does it imply also that it does not belong to CX?
- CX_MEMBERSHIP_TEST = 1 means the point belongs to CX.
- CX_MEMBERSHIP_TEST = 0 means the point does not belong to CX.

## Details about TRIVIAL_ALL_INFTY, TRIVIAL_WITH_MEMBERSHIP_CHECK and non_trivial 

- TRIVIAL_ALL_INFTY, TRIVIAL_WITH_MEMBERSHIP_CHECK are counter-constant binary
- is_bls_pairing_check = 0 => TRIVIAL_ALL_INFTY = 0, TRIVIAL_WITH_MEMBERSHIP_CHECK = 0
- SUCCESS_BIT = 0 => TRIVIAL_ALL_INFTY = 0, TRIVIAL_WITH_MEMBERSHIP_CHECK = 0
- ... similar constraints to TRIVIAL_PAIRING in the ecdata case ...

Here we focus on the differences with respect to ecdata and the relations among the columns used to determine the triviality cases:

Assuming SUCCESS_BIT = 1, we have:

- To distinguish in case we are we need 2 columns, TRIVIAL_ALL_INFTY and TRIVIAL_WITH_MEMBERSHIP_CHECK, and a shorthand, non_trivial.
At the first row of BLS_PAIRING_CHECK we assume both triviality cases are true, thus:
- IS_BLS_PAIRING_CHECK_DATA_{i-1} = 0 && IS_BLS_PAIRING_CHECK_DATA_i = 1 => TRIVIAL_ALL_INFTY = 1, TRIVIAL_WITH_MEMBERSHIP_CHECK = 1

As soon as we find a pair in which at least one point is not at infinity:
- TRIVIAL_ALL_INFTY = 0

As soon as we find a pair in which both points are not at infinity:
- TRIVIAL_WITH_MEMBERSHIP_CHECK = 0

Note that the first pair in which at least one point is not at infinity may also be the first pair in which both points are not at infinity.

non_trivial may be a shorthand that is true when both triviliaty cases are false (under the SUCCESS_BIT = 1 assumption):

- non_trivial = (1 - TRIVIAL_ALL_INFTY) * (1 - TRIVIAL_WITH_MEMBERSHIP_CHECK)

In order to determine in which case we are, we need to look at the last row of BLS_PAIRING_CHECK data.

## Update

Note NOT_ON_... columns have been replaced by MALFORMED_DATA_EXTERNAL_JUSTIFICATION.