# Module structure

A likely good structure for the module is

|-----------|--------|-----------|---------------------------|
|           |        |   CT_MAX  | notes                     |
|-----------|--------|:---------:|---------------------------|
| WCP       | rows * | <determ.> |
|-----------|--------|:---------:|
| MACRO     | row    |     0     |
|-----------|--------|:---------:|---------------------------|
| RLP_UTILS | rows * | <determ.> |                           |
|           |        |           | processing phase columns: |
|           |        |           | .   IS_GLOBAL_PREFIX      |
|           |        |           | .   IS_CHAIN_ID           |
|           |        |           | .   IS_ADDRESS            |
|           |        |           | .   IS_Y_PARITY           |
|           |        |           | .   IS_R                  |
|           |        |           | .   IS_S                  |
|-----------|--------|-----------|---------------------------|

# Lookups

## Lookup to WCP

We need comparisons (ali ≡ authority list item) to verify MANDATORY PRECONDITIONS

|-----------------|--------------|----------|-----|-----------------------|
| WCP instruction | arg1         | arg2     | res | note                  |
|-----------------|--------------|----------|-----|-----------------------|
| LT              | ali.nonce    | 1 << 64  |     | result must be <true> |
| LT              | ali.address  | 1 << 20  |     | result must be <true> |
| LT              | ali.y_parity | 1 << 8   |     | result must be <true> |
| LT              | ali.r        | 1 << 256 |     | result must be <true> |
| LT              | ali.s        | 1 << 256 |     | result must be <true> |
|-----------------|--------------|----------|-----|-----------------------|


We also need comparisons that are ALLOWED TO FAIL

|-----------------|---------------|------------------|-------------------------|--------------------------------------------------------------------|
| WCP instruction | arg1          | arg2             | res                     | note                                                               |
|-----------------|---------------|------------------|-------------------------|--------------------------------------------------------------------|
| ISZERO          | ali.chain_id  |                  | chain_id_is_0           |                                                                    |
| EQ              | ali.chain_id  | β                | chain_id_is_β           |                                                                    |
| LT              | ali.nonce     | (2 << 64) - 1    | valid_nonce_bound       |                                                                    |
| LT              | ali.s         | secp256k1 / 2    | valid_s                 |                                                                    |
| EQ              | ali.nonce     | hub.acc/NONCE    | nonce_agreement         | potentially compare ali.nonce with acc/nonce + SENDER_IS_AUTHORITY |
| EQ              | ali.authority | txndata.hub/FROM | sender_is_authority     |                                                                    |
| ISZERO          | ali.address   |                  | address_is_zero_address |                                                                    |
|-----------------|---------------|------------------|-------------------------|--------------------------------------------------------------------|


## Lookup to RLP_UTILS

We need to RLP-ize the authority list items. Recall that these are of the form

    item ≡ [ chain_id, address, nonce, y_parity, r, s ]

With
- chain_id ≡ integer, 32B at most, rlp-ization: 1B to 33B
- address  ≡ address, 20B exactly, rlp-ization: 21B
- y_parity ≡ integer,  1B at most, rlp-ization: 1B or 2B
- r        ≡ integer, 32B at most, rlp-ization: 1B to 33B
- s        ≡ integer, 32B at most, rlp-ization: 1B to 33B

so that

    ζ ≡ RLP( chain_id ) ∙ RLP( address ) ∙ RLP( nonce ) ∙ RLP( y_parity ) ∙ RLP( r ) ∙ RLP( s ) ∈ B_k

where k ∈ {25, ..., 122}. So that

    RLP( item ) ≡ RLP( ζ )
                ≡ <rlp prefix> ∙ ζ

and so we must call `RLP_UTILS` for

| RLP_UTILS instruction | argument      | notes |
|-----------------------|---------------|-------|
| BYTESTRING            | global prefix |       |
| INTEGER               | chain_id      |       |
| ADDRESS               | address       |       |
| INTEGER               | nonce         |       |
| INTEGER               | y_parity      |       |
| INTEGER               | r             |       |
| INTEGER               | s             |       |
|-----------------------|---------------|-------|

## Lookup to BLOCK_DATA

We need to justify the network chain id β.

## Lookup to TXN_DATA

The goals of this lookup are to
- justify the transaction FROM address
- this is required so that we can justify `SENDER_IS_AUTHORITY`

- selector: `rlp_auth.MACRO`
- correspondence:

|-----------------------------|------------------------------|
| `RLP_AUTH` columns          | `TXN_DATA` columns           |
|-----------------------------|------------------------------|
| 1                           | txn_data.HUB                 |
| 1                           | txn_data.rlp/TYPE_4[-1]      |
| rlp_auth.USER_TXN_NUMBER    | txn_data.USER_TXN_NUMBER     |
| rlp_auth.macro/AUTHORITY_HI | rlp_data.hub/FROM_ADDRESS_HI |
| rlp_auth.macro/AUTHORITY_LO | rlp_data.hub/FROM_ADDRESS_LO |
|-----------------------------|------------------------------|

## Lookup RLP_AUTH → RLP_TXN

This lookup ensures that the `RLP_AUTH` module does not deal with more authorization list tuples than required.
Unclear at the moment whether this is necessary.

- selector: `rlp_auth.MACRO`
- correspondence:

|--------------------------------|-------------------------------|
| `RLP_AUTH` columns             | `RLP_TXN` columns             |
|--------------------------------|-------------------------------|
| 1                              | rlp_txn.AUTH                  |
| rlp_auth.USER_TXN_NUMBER       | rlp_txn.USER_TXN_NUMBER       |
| rlp_auth.AUTHORITY_TUPLE_INDEX | rlp_txn.AUTHORITY_TUPLE_INDEX |
|--------------------------------|-------------------------------|

## Lookup RLP_TXN → RLP_AUTH

This lookup provides the `RLP_AUTH` with its instructions.

- selector: `rlp_txn.AUTH`, the AUTH "subperspective" is yet to be specified
- correspondence:

|-------------------------------------------|---------------------------------------------|------------------------------|
| `RLP_TXN` columns                         | `RLP_AUTH` columns                          | notes                        |
|-------------------------------------------|---------------------------------------------|------------------------------|
| 1                                         | rlp_auth.MACRO                              |                              |
| rlp_txn.USER_TXN_NUMBER                   | rlp_auth.USER_TXN_NUMBER                    |                              |
| rlp_txn.auth/AUTHORITY_TUPLE_INDEX        | rlp_auth.AUTHORITY_TUPLE_INDEX              |                              |
|-------------------------------------------|---------------------------------------------|------------------------------|
| rlp_txn.auth/CHAIN_ID_HI                  | rlp_auth.macro/CHAIN_ID_HI                  | raw data from the            |
| rlp_txn.auth/CHAIN_ID_LO                  | rlp_auth.macro/CHAIN_ID_LO                  | authorization list           |
| rlp_txn.auth/ADDRESS_HI                   | rlp_auth.macro/ADDRESS_HI                   |                              |
| rlp_txn.auth/ADDRESS_LO                   | rlp_auth.macro/ADDRESS_LO                   |                              |
| rlp_txn.auth/ACCESS_TUPLE_NONCE           | rlp_auth.macro/ACCESS_TUPLE_NONCE           |                              |
| rlp_txn.auth/SIGNATURE_Y                  | rlp_auth.macro/SIGNATURE_Y                  |                              |
| rlp_txn.auth/SIGNATURE_R_HI               | rlp_auth.macro/SIGNATURE_R_HI               |                              |
| rlp_txn.auth/SIGNATURE_R_LO               | rlp_auth.macro/SIGNATURE_R_LO               |                              |
| rlp_txn.auth/SIGNATURE_S_HI               | rlp_auth.macro/SIGNATURE_S_HI               |                              |
| rlp_txn.auth/SIGNATURE_S_LO               | rlp_auth.macro/SIGNATURE_S_LO               |                              |
|-------------------------------------------|---------------------------------------------|------------------------------|
| rlp_txn.auth/IS_VALID_TUPLE               | rlp_auth.macro/IS_VALID_TUPLE               |                              |
|-------------------------------------------|---------------------------------------------|------------------------------|
| rlp_txn.auth/AUTHORITY_RECOVERY_SUCCESS   | rlp_auth.macro/AUTHORITY_RECOVERY_SUCCESS   |                              |
| rlp_txn.auth/AUTHORITY_HI                 | rlp_auth.macro/AUTHORITY_HI                 |                              |
| rlp_txn.auth/AUTHORITY_LO                 | rlp_auth.macro/AUTHORITY_LO                 |                              |
|-------------------------------------------|---------------------------------------------|------------------------------|
| rlp_txn.auth/SENDER_IS_AUTHORITY          | rlp_auth.macro/SENDER_IS_AUTHORITY          |                              |
| rlp_txn.auth/ADDRESS_IS_ZERO_ADDRESS      | rlp_auth.macro/ADDRESS_IS_ZERO_ADDRESS      |                              |
|-------------------------------------------|---------------------------------------------|------------------------------|
| rlp_txn.auth/AUTHORITY_NONCE              | rlp_auth.macro/AUTHORITY_NONCE              | read from the HUB            |
| rlp_txn.auth/AUTHORITY_HAS_CODE           | rlp_auth.macro/AUTHORITY_HAS_CODE           | read from the HUB            |
| rlp_txn.auth/AUTHORITY_IS_DELEGATED       | rlp_auth.macro/AUTHORITY_IS_DELEGATED       | read from the HUB            |
|-------------------------------------------|---------------------------------------------|------------------------------|
| rlp_txn.auth/POTENTIALLY_NEW_CODE_HASH_HI | rlp_auth.macro/POTENTIALLY_NEW_CODE_HASH_HI | either empty code hash       |
| rlp_txn.auth/POTENTIALLY_NEW_CODE_HASH_LO | rlp_auth.macro/POTENTIALLY_NEW_CODE_HASH_LO | or KEC( ef0100 ∙ <address> ) |
|-------------------------------------------|---------------------------------------------|------------------------------|

## Lookup RLP_TXN -> HUB

To transmit to transmit the access list tuple to the HUB. It also
The `HUB` should operate under the same order as the transaction has its stuff RLP-ized:
1. access list
2. authorization list

- selector: `sel ≡ rlp_txn.AUTH ∙ rlp_txn.auth/AUTHORITY_RECOVERY_SUCCESS`
- correspondence:

|-------------------------------------------|------------------------------------------------|-------------------------------------------------------|
| RLP_TXN columns                           | HUB columns                                    | notes                                                 |
|-------------------------------------------|------------------------------------------------|-------------------------------------------------------|
| 1                                         | hub.auth                                       |                                                       |
| rlp_txn.USER_TXN_NUMBER                   | hub.USER_TXN_NUMBER                            |                                                       |
| rlp_txn.auth/AUTHORITY_TUPLE_INDEX        | hub.auth/AUTHORITY_TUPLE_INDEX                 |                                                       |
| rlp_txn.auth/IS_VALID_TUPLE               | hub.auth/IS_VALID_TUPLE                        | used to decide whether to do something or not         |
| rlp_txn.auth/ADDRESS_HI                   | hub.auth/POTENTIALLY_NEW_DELEGATION_ADDRESS_HI | hub.account/DELEGATION_ADDRESS_HI_NEW will also exist |
| rlp_txn.auth/ADDRESS_LO                   | hub.auth/POTENTIALLY_NEW_DELEGATION_ADDRESS_LO | hub.account/DELEGATION_ADDRESS_LO_NEW                 |
| rlp_txn.auth/ADDRESS_IS_ZERO_ADDRESS      | hub.auth/POTENTIALLY_RESET_DELEGATION          |                                                       |
| rlp_txn.auth/POTENTIALLY_NEW_CODE_HASH_HI | hub.auth/POTENTIALLY_NEW_CODE_HASH_HI          | new columns: place where to write potential updated   |
| rlp_txn.auth/POTENTIALLY_NEW_CODE_HASH_LO | hub.auth/POTENTIALLY_NEW_CODE_HASH_LO          | code hash                                             |
|-------------------------------------------|------------------------------------------------|-------------------------------------------------------|
| rlp_txn.auth/AUTHORITY_HI                 | hub.account/ADDRESS_HI                         |                                                       |
| rlp_txn.auth/AUTHORITY_LO                 | hub.account/ADDRESS_LO                         |                                                       |
| rlp_txn.auth/AUTHORITY_NONCE              | hub.account/NONCE                              |                                                       |
| rlp_txn.auth/AUTHORITY_HAS_CODE           | hub.account/HAS_CODE                           |                                                       |
| rlp_txn.auth/AUTHORITY_IS_DELEGATED       | hub.account/IS_DELEGATED                       | hub.account/IS_DELEGATED_NEW will also exist          |
|-------------------------------------------|------------------------------------------------|-------------------------------------------------------|

