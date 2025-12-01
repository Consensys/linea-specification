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


## MODEXP xbs limit tests

This family of tests explores the 'within bounds / out of bounds' distinction of the
xbs parameters of `MODEXP` calls. Recall that starting with Osaka the Linea zkEVM is able
to prove the same breadth of `MODEXP` calls as the Osaka EVM, and that such calls are
deemed exceptional if any one of `bbs`, `ebs` or `mbs` (potentially extracted from RAM,
right zero padded) is `> 1024`.

We want the following families of tests.

```
Test families:
==============

// one out of bonds xbs
BBS_OUT_OF_BOUNDS
EBS_OUT_OF_BOUNDS
MBS_OUT_OF_BOUNDS

// two out of bonds xbs'
BBS_AND_EBS_OUT_OF_BOUNDS
BBS_AND_MBS_OUT_OF_BOUNDS
MBS_AND_BBS_OUT_OF_BOUNDS

// all xbs out of bonds
ALL_XBS_OUT_OF_BOUNDS


⇒ 7 test families

Xbs range types:
================

UNCONDITIONALLY_VALID
CONDITIONALLY_VALID   | ← both considered !isValid(), call them not
INVALID               |

The idea is that we will construct call data like so

call_data = <bbs> | <ebs> | <mbs> | <3 * 1024 bytes of gibberish>

we will want to populate the values of the xbs according to the following

|---------------------------|-----------------------|-----------------------|-----------------------|
| Test family               |     bbs range type    |     ebs range type    |     mbs range type    |
|---------------------------|:---------------------:|:---------------------:|:---------------------:|
| BBS_OUT_OF_BOUNDS         |          not          | UNCONDITIONALLY_VALID | UNCONDITIONALLY_VALID |
| EBS_OUT_OF_BOUNDS         | UNCONDITIONALLY_VALID |          not          | UNCONDITIONALLY_VALID |
| MBS_OUT_OF_BOUNDS         | UNCONDITIONALLY_VALID | UNCONDITIONALLY_VALID |          not          |
| BBS_AND_EBS_OUT_OF_BOUNDS |          not          |          not          | UNCONDITIONALLY_VALID |
| BBS_AND_MBS_OUT_OF_BOUNDS | UNCONDITIONALLY_VALID |          not          |          not          |
| MBS_AND_BBS_OUT_OF_BOUNDS |          not          |          not          | UNCONDITIONALLY_VALID |
| ALL_XBS_OUT_OF_BOUNDS     |          not          |          not          |          not          |
|---------------------------|-----------------------|-----------------------|-----------------------|

⇒ 3 XbsRangeType variants

Valid ranges:
=============

0x 0000
0x 0001
0x 0020
0x 031e
0x 0400

⇒ 5 valid ranges

Conditionally valid ranges:
===========================

0x 0401
0x 04ff

⇒ 2 conditionally valid ranges

Invalid ranges:
===============

INVALID ≡ SMALL_INVALID_XBS
        | LARGE_INVALID_XBS

SMALL_INVALID_XBS ≡ 0x 00 .. 00 | <trailing>     // nonzero <trailing>
LARGE_INVALID_XBS ≡  <leading>  | <trailing>

0x <leading> <trailing>
   <--16B--> <--16B-->

<leading> = 0x 00 .. 01
          | 0x <random>
          | 0x ff .. ff

<trailing> ≡ 0x 00 .. 00 00
           | 0x <random>
           | 0x ff .. ff ff
           | 0x 00 .. 04 01
           | 0x 00 .. 05 00

⇒ 4 + 3 * 5 = 19 invalid ranges

CDS variants:
=============

// there is no need to give interesting values to data beyond mbs
// the operation must fail before loading anything from there given
// that we act on [[OOB_INST_MODEXP_lead]] only under the condition
// that all xbs are in range.

NO_CONDITIONALLY_VALID_XBS ≡ 96 + 3 * 1024

SOME_CONDITIONALLY_VALID_XBS ≡ 32 - 1   // if bbs is the first conditionally valid xbs
                             | 64 - 1   // if ebs ...
                             | 96 - 1   // if mbs ...

If none of the XBS are conditionally valid we use the following variants
```



Dimensions of testing
- xbs'
```
valid ranges:
0x0000
0x0001
0x0020
0x031e
0x0400

conditionally valid ranges:
0x0401
0x04ff

invalid ranges:
0x0500
0x <[leading]> <trailing>
   <--16B--> <--16B-->

<leading> = 0x 00 .. 00
          | 0x 00 .. 01
          | 0x <random>
          | 0x ff .. ff

<trailing> ≡ 0x 00 .. 00
           | 0x <random>
           | 0x ff .. ff

These xbs are only valid for
// only for cds = 32 - 1, 64 - 1, 96 - 1
0x  00  .. 00   ??    ..   ?? // and cds = 32 - l
    <k bytes>  <32 - k bytes>
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
