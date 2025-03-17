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
Each coordinate is 48 bytes.

small point (point supposed to be on G1):

(Ax, Ay)

large point (point supposed to be on G2):

(BxIm, BxRe, ByIm, ByRe)

Thus, each requires 3 half ewords:

e.g.,

Ax_hi, Ax_mi, Ax_lo

```

## Checks performed by the arithmetization
- Coordinate encoding
- Input length, specifically whether a small point coordinate belongs to $\mathbb{F}_p$ ($< p$) or a large point coordinate belongs to $\mathbb{F}_{p^2}$ ($< p^2$).
- Point at infinity

## Checks performed by external circuits
- $\mathbb{G}_1$ and $\mathbb{G}_1$ subgrpup mermbership
- $\mathbb{G}_2$ and $\mathbb{G}_2$ subgrpup mermbership

## Checks overview

- BLS12_G1ADD,  $P \times Q$ (256 bytes) $\rightarrow R$ (128 bytes)
    * coordinate encoding
    * input length
    * points at infinity
    * $\mathbb{G}_1$ mermbership         
- BLS12_G1MSM, $(P \times N)^k$ ($160 \cdot k$ bytes) $\rightarrow R$ (128 bytes) with $k > 0$
    * coordinate encoding
    * input length
    * point at infinity
    * $\mathbb{G}_1$ and $\mathbb{G}_1$ subgrpup mermbership        
- BLS12_G2ADD $P \times Q$ (512 bytes) $\rightarrow R$ (256 bytes)
    * coordinate encoding
    * input length
    * points at infinity
    * $\mathbb{G}_2$ mermbership              
- BLS12_G2MSM $(P \times N)^k$ ($288 \cdot k$ bytes) $\rightarrow R$ (256 bytes) with $k > 0$         
    * coordinate encoding
    * input length
    * point at infinity
    * $\mathbb{G}_2$ and $\mathbb{G}_2$ subgrpup mermbership 
- BLS12_PAIRING_CHECK $(A \times B)^k$ ($384 \cdot k$ bytes) $\rightarrow \{0,1\}$ (right padded to 32 bytes) with $k > 0$    
    * coordinate encoding
    * input length
    * point at infinity
    * $\mathbb{G}_1$ and $\mathbb{G}_1$ subgrpup mermbership   
    * $\mathbb{G}_2$ and $\mathbb{G}_2$ subgrpup mermbership 
- BLS12_MAP_FP_TO_G1  
- BLS12_MAP_FP2_TO_G2 

Note that addition operations do not require subgroup membership checks. In case the operations are execute on point not in the respective subgroups, also the result will not be in the subgroup.
A user who wants addition and subgroup membership check can use MSM(P,Q,1,1)=P+Q since MSM precompile does subgroup check.