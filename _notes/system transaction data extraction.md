# EIP-4788 (starting with Cancun)

selector: SYSI ∙ hub/EIP-4788
data:
- timestamp: SYST_TXN_DATA_1
- beacon_root_hi: split in SYST_TXN_DATA_3
- beacon_root_lo: split in SYST_TXN_DATA_4

You grab the data on the rows where the selector is ≡ 1
You'll get one row per block where the selector is ≡ 1
The beacon root is part of the block header.


# EIP-2935 (starting with Prague)

selector: SYSI ∙ hub/EIP-2935
data:
- prev_block_number: SYST_TXN_DATA_1
- prev_block_hash_hi: split in SYST_TXN_DATA_3
- prev_block_hash_lo: split in SYST_TXN_DATA_4

You grab the data on the rows where the selector is ≡ 1
You'll get one row per block where the selector is ≡ 1
The beacon root is part of the block header.

