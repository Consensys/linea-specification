# `MODEXP` test vectors for Osaka

## MODEXP pricing + the 500 boundary testing

With MODEXP pricing we have several interesting questions
- the new pricing of the log of the exponent
- the comparison to 500

The cost of MODEXP is now

   cost ≡ 500 ∨ ζ
   ζ ≡ (l + 16 ∙ x) ∙ 2 ∙ words^2

with l ≡ lead_log, x ≡ (ebs - 32) ∨ 0, words ≡ ⌈max(mbs, bbs)/8⌉.

Testing will explore these variables somewhat extensively. We should test like so
```
bbs / mbs pairs
===============

(bbs, mbs) ∈ { (0,0), (0, 3), (21, 37), (56, 55) }

|------------|-----|-------|---------|
| (bbs, mbs) | max | words | words^2 |
|------------|-----|-------|---------|
| (0, 0)     | 0   | 0     | 0       |
| (0, 3)     | 3   | 1     | 1       |
| (21, 23)   | 23  | 3     | 9       |
| (56, 55)   | 56  | 7     | 49      |
|------------|-----|-------|---------|

NOTE: The (0,3) case gives us the most fine grained exploration of the 500 vs ζ boundary

⇒ there are 4 options

cds options:
============

cds ≡ 96 + bbs + extra, extra ∈ { ebs / 2, ebs, ebs + mbs }

⇒ there are 3 options

ebs options:
============

ebs ≡ 0, 1, 16, 27, 32, 39, 173 where the first (ebs ∧ 32) bytes are, in base two,

   0b 00 .. 00 11 .. 11

with z ∈ {0, 1, ..., 8 ∙ (ebs ∧ 32) } one's (and lead_log ≡ 0, 1, ..., 8 ∙ (ebs ∧ 32))

⇒ there are (0 + 1 + 16 + 27 + 32 + 32 + 32) ∙ 8 + 7 ≡ 1127 options

Total options:
==============

   4 ∙ 3 ∙ 1127 ≡ 13524 variants
```

Dimensions of testing
- xbs'
```
valid ranges:
0x0000
0x0001
0x0020
0x0100
0x0200
0x02?? // only for cds = 32 - 1, 64 - 1, 96 - 1
0x  00  .. 00   ??    ..   ?? // and cds = 32 - l
    <k bytes>  <32 - k bytes>

invalid ranges:
0x201
0x <leading> <trailing>
   <--16B--> <--16B-->

<leading> = 0x 00 .. 00
          | 0x 00 .. 01
          | 0x <random>
          | 0x ff .. ff

<trailing> ≡ <valid>
           | 0x <random>
           | 0x ff .. ff
```

families of tests

- call_data_only_covers_parts_of_bbs: 00 < cds ≤ 32
- call_data_only_covers_parts_of_ebs: 32 < cds ≤ 64
- call_data_only_covers_parts_of_mbs: 64 < cds ≤ 96

Those tests we can do the (k,l) testing

```
invalid_bbs_call_data   ≡   0x 00 .. 02 ff | ff .. ff ff | ff .. ff ff
                               <---bbs---> | <---ebs---> | <---mbs--->

invalid_ebs_call_data   ≡   0x 00 .. 01 00 | 00 .. 02 ff | ff .. ff ff
                               <---bbs---> | <---ebs---> | <---mbs--->

invalid_mbs_call_data   ≡   0x 00 .. 01 00 | 00 .. 01 80 | 00 .. 02 ff
                               <---bbs---> | <---ebs---> | <---mbs--->

we apply a mask

bbs_mask(k) ≡ 0x 00 .. 00 03 ff .. ff | 'ff'.repeat(32) | 'ff'.repeat(32)
bbs_cds(k)  ≡ 
```
