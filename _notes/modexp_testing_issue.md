# xbs tests

test all variations of bbs, ebs, mbs
we already have tests that test valid byte sizes, we just need to expand their range
what is new are tests with invalid byte sizes (>512) which Linea will support as of Osaka.

```rust
// what follows are values for xbs ≡ bbs, ebs, mbs
VALID_BYTE_SIZES ≡
    | 0
    | 1
    | 15
    | 16
    | 256
    | 512

INVALID_BYTE_SIZES ≡
    | 513
    | <random 16B integer>
    | 256**16 - 1  // 0x00ff..ff
    | 256**16      // 0x0100..00
    | <random 32B integer>
    | 2**256 - 1
```

# pricing tests

```rust
// ebs gets compared to in the pricing: ebs > 32 ?
VALID_EXPONENT_BYTE_SIZES ≡
    | 0
    | 32
    | 33
    | 256
    | 512

// maxBbsMbs ≡ max(bbs, mbs) gets compared to 32: maxBbsMbs > 32 ?
VALID_BASE_AND_MODULUS_BYTE_SIZES ≡
    | 0
    | 31
    | 32
    | 33
    | 256
    | 512

LEADING_WORD_OF_EXPONENT ≡
    | 0x00 .. 00
    | 0x00 .. 01
    | 0x00 .. 00 aa .. aa (at some spot)
```

# xbs tests and pricing

In these tests we want to test the simultaneous success / failure of xbs and pricing tests.

```rust
VALID_BYTE_SIZES ≡
    | VALID(51)
    | MAX(512)
    | INVALID(666)

// the EXACT value has to be computed from parameters
GAS_PARAM ≡
    | INSUFFICIENT
    | EXACT
    | EXACT_PO
```

