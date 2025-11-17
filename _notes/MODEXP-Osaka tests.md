# `MODEXP` test vectors for Osaka

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
