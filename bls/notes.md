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

p2 = p * p
Fp quadratic non-residue = nr2 = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaaa
Fp2 is Fp[X]/(X^2-nr2)
Curve Fp2 equation: Y^2 = X^3 + B*(v+1) where v is the square root of nr2
```

## Points

```
Each coordinate is represented using 64 bytes, where the first 16 bytes are supposed to be 0s and the remaining 48 bytes represent the actual value:

small point (point supposed to be on G1):

(Ax, Ay)

large point (point supposed to be on G2):

(BxIm, BxRe, ByIm, ByRe)

Thus, each requires 4 half ewords:

e.g.,

Ax_hh, Ax_hl, Ax_lh, Ax_ll

```

## Checks performed by the arithmetization
- Coordinate encoding
- Input length, specifically whether a small point coordinate belongs to $\mathbb{F}_p$ ($< p$) or a large point coordinate belongs to $\mathbb{F}_{p^2}$ ($< p^2$).
- Point at infinity

## Checks performed by external circuits

Let $\mathbb{G}_1$ be $\mathbb{C}_1$ subgroup and $\mathbb{G}_2$ be $\mathbb{C}_2$ subgroup.

- $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership
- $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership

## Checks overview

- BLS12_G1ADD,  $\mathbb{C_1} \times \mathbb{C_1}$ (256 bytes) $\rightarrow \mathbb{C_1}$ (128 bytes)
    * coordinate encoding
    * input length
    * points at infinity
    * $\mathbb{C}_1$ mermbership         
- BLS12_G1MSM, $(\mathbb{G_1} \times \mathbb{N})^k$ ($160 \cdot k$ bytes) $\rightarrow \mathbb{G_1}$ (128 bytes) with $k > 0$
    * coordinate encoding
    * input length
    * point at infinity
    * $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership        
- BLS12_G2ADD $\mathbb{C_2} \times \mathbb{C_2}$ (512 bytes) $\rightarrow \mathbb{C_2}$ (256 bytes)
    * coordinate encoding
    * input length
    * points at infinity
    * $\mathbb{C}_2$ mermbership              
- BLS12_G2MSM $(\mathbb{G_2} \times \mathbb{N})^k$ ($288 \cdot k$ bytes) $\rightarrow \mathbb{G_2}$ (256 bytes) with $k > 0$         
    * coordinate encoding
    * input length
    * point at infinity
    * $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership 
- BLS12_PAIRING_CHECK $(\mathbb{G_1} \times \mathbb{G_2})^k$ ($384 \cdot k$ bytes) $\rightarrow \{0,1\}$ (right padded to 32 bytes) with $k > 0$    
    * coordinate encoding
    * input length
    * point at infinity
    * $\mathbb{C}_1$ and $\mathbb{G}_1$ mermbership   
    * $\mathbb{C}_2$ and $\mathbb{G}_2$ mermbership 
- BLS12_MAP_FP_TO_G1 $\mathbb{F}_p$ (64 bytes) $\rightarrow \mathbb{G_1}$ (128 bytes)
    * coordinate encoding
    * input length
- BLS12_MAP_FP2_TO_G2 $\mathbb{F}_{p^2}$ (128 bytes) $\rightarrow \mathbb{G_2}$ (256 bytes)
    * coordinate encoding
    * input length 

Note that addition operations do not require subgroup membership checks. 
In case the operations are executed on points not in the subgroup, also the result will not be in the subgroup.
A user who wants addition and subgroup membership check can use $MSM((P,1),(Q,1))=P \times 1 + Q \times 1 = P + Q$ since MSM precompile does subgroup membership check.

## Modules

Beyond creating an new BLS module, the following existing modules will be affected:

- HUB:  precompile processing
- OOB:  for detecting `FAILURE_KNOWN_TO_HUB`
- TRM:  for updated `IS_PRECOMPILE` flag
- MMIO: for lookup to new BLS module

## Comparisons

All comparisons will require two interactions with WCP (48 byte data):

```

wcpGeneralizedCallToLT(A_hh, A_hl, A_lh, A_ll, B_hh, B_hl, B_lh, B_ll)

<=>

wcpCallToLT(A_hh, A_hl, B_hh, B_hl)

or 

wcpCallToEQ(A_hh, A_hl, B_hh, B_hl)


```


