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
    * Recognize which precompile we are dealing with.
- OOB:
    * Input length check, i.e., the call data size is equal or multiple of an expected number. 
    * Gas check, i.e., enough gas is provided.
- BLS:
    * Coordinate encoding check, specifically whether a small point coordinate belongs to $\mathbb{F}_p$ or a large point coordinate belongs to $\mathbb{F}_{p^2}$ ($< p$ for every coordinate).
    * Point at infinity check.
    * By potentially interacting with external circuits, justifying the success bit of the operation.

## Operations performed by external circuits

Let $\mathbb{G}_1$ be $\mathbb{C}_1$ subgroup and $\mathbb{G}_2$ be $\mathbb{C}_2$ subgroup.

- $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership check.
- $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership check.
- The actual precompiles computation.

## Checks overview

- BLS12_G1ADD,  $\mathbb{C_1} \times \mathbb{C_1}$ (256 bytes) $\rightarrow \mathbb{C_1}$ (128 bytes)
    * input length
    * Gas check
    ---
    * coordinate encoding
    * points at infinity
    * $\mathbb{C}_1$ mermbership         
- BLS12_G1MSM, $(\mathbb{G_1} \times \mathbb{N})^k$ ($160 \cdot k$ bytes) $\rightarrow \mathbb{G_1}$ (128 bytes) with $k > 0$
    * input length
    * Gas check
    ---
    * coordinate encoding
    * point at infinity
    * $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership        
- BLS12_G2ADD $\mathbb{C_2} \times \mathbb{C_2}$ (512 bytes) $\rightarrow \mathbb{C_2}$ (256 bytes)ù
    * input length
    * Gas check
    ---
    * coordinate encoding
    * points at infinity
    * $\mathbb{C}_2$ mermbership              
- BLS12_G2MSM $(\mathbb{G_2} \times \mathbb{N})^k$ ($288 \cdot k$ bytes) $\rightarrow \mathbb{G_2}$ (256 bytes) with $k > 0$     
    * input length
    * Gas check
    ---    
    * coordinate encoding
    * point at infinity
    * $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership 
- BLS12_PAIRING_CHECK $(\mathbb{G_1} \times \mathbb{G_2})^k$ ($384 \cdot k$ bytes) $\rightarrow \{0,1\}$ (right padded to 32 bytes) with $k > 0$    
    * input length
    * Gas check
    ---
    * coordinate encoding
    * point at infinity
    * $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership   
    * $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership 
- BLS12_MAP_FP_TO_G1 $\mathbb{F}_p$ (64 bytes) $\rightarrow \mathbb{G_1}$ (128 bytes)
    * input length
    * Gas check
    ---
    * coordinate encoding
- BLS12_MAP_FP2_TO_G2 $\mathbb{F}_{p^2}$ (128 bytes) $\rightarrow \mathbb{G_2}$ (256 bytes)
    * input length
    * Gas check
    ---
    * coordinate encoding

Note that addition operations do not require subgroup membership checks. 
In case the operations are executed on points not in the subgroup, also the result will not be in the subgroup.
A user who wants addition and subgroup membership check can use $MSM((P,1),(Q,1))=P \times 1 + Q \times 1 = P + Q$ since MSM precompile does subgroup membership check.

## Modules

Beyond creating an new BLS module (and BLS_REFTABLE), the following existing modules will be affected:

- HUB:  precompile processing.
- OOB:  for detecting `FAILURE_KNOWN_TO_HUB`, specifically checking if the call data size is acceptable (e.g., similarly to multiple of 192 for ECDATA ecpairing), if enough gas is provided etc. If input is 0 also, the HUB needs to know it and we do not trigger RAM and BLS at all. @TODO: find exact conditions to check before potentially triggering BLS.
- TRM:  for updating the range check that justifies the `IS_PRECOMPILE` flag, that is identifying which precompile we are dealing with.
- MMIO: for lookup to new BLS module.

HUB  - is it a precomopile?           -> TRM
HUB  - input length (cds) valid? gas? -> OOB? <- Focus on this (cds, gas, discount @TODO: create REFTABLE which is a new module)
If it makes sense:
HUB  -                                -> MMU  
MMU  -                                -> MMIO
If it makes sense:
MMIO -                                -> BLS

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

### Failure case (assuming ICP = 1)

- BLS12_G1ADD: send to C1_MEMBERSHIP circuit the first point predicted not to be in C1, so as to prove non-membership.            
- BLS12_G1MSM: if a point is predicted not to be in C1, then send it to C1_MEMBERSHIP circuit, so as to prove non-membership.
If a point is predicted to not be in G1, then send it directly to G1_MEMBERSHIP circuit, so as to prove non-membership.
- BLS12_G2ADD: send to C2_MEMBERSHIP circuit the first point predicted not to be in C2, so as to prove non-membership.           
- BLS12_G2MSM: if a point is predicted not to be in C2, then send it to C2_MEMBERSHIP circuit, so as to prove non-membership.
if a point is predicted to not be in the G2, then send it directly to G2_MEMBERSHIP circuit, so as to prove non-membership.
- BLS12_PAIRING_CHECK: send to G1_MEMBERSHIP or G2_MEMBERSHIP circuits the first point predicted not to be in the C1,2 or G1,2, so as to prove non-membership.     
- BLS12_MAP_FP_TO_G1: no circuit needed.
- BLS12_MAP_FP2_TO_G2: no circuit needed.

### Success case (assuming ICP = 1 and NOT_ON_G1_MAX = NOT_ON_G2_MAX = 0)

- BLS12_G1ADD: send to C1_MEMBERSHIP circuits all points so as to prove membership to C1, then send them to G1_ADD circuit
- BLS12_G1MSM: send to G1_MEMBERSHIP circuits all points so as to prove membership to C1 and G1, then send them to G1_MSM circuit.
- BLS12_G2ADD: send to C2_MEMBERSHIP circuits all points so as to prove membership to C2, then send them to G2_ADD circuit.
- BLS12_G2MSM: send to G2_MEMBERSHIP circuits all points so as to prove membership to C2 and G2, then send them to G2_MSM circuit.
- BLS12_PAIRING_CHECK: 
    * If all points are trivial (small and large point are at infinity) do nothing.
    * If small point is trivial, then send large point to G2_MEMBERSHIP circuit to prove membership to C2 and G2.
    * If large point is trivial, then send small point to G1_MEMBERSHIP circuit to prove membership to C1 and G1.
    * If neither small nor large points are trivial, send the pair to the PAIRING circuit. 
- BLS12_MAP_FP_TO_G1: send field element to MAP_FP_TO_G1 circuit.
- BLS12_MAP_FP2_TO_G2: send field element to MAP_FP2_TO_G2 circuit.