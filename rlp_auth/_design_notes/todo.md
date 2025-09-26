# Module structure

A likely good structure for the module is

|-----------|--------|-----------|--------------------------------|
|           |        |   CT_MAX  | notes                          |
|-----------|--------|:---------:|--------------------------------|
| WCP       | rows * | <determ.> |                                |
|           |        |           | This comprises both            |
|           |        |           | .   MANDATORY PRECONDITIONS    |
|           |        |           | .   VALIDITY CHECK COMPARISONS |
|-----------|--------|:---------:|--------------------------------|
| MACRO     | row    |     0     |
|-----------|--------|:---------:|--------------------------------|
| RLP_UTILS | rows * | <determ.> |                                |
|           |        |           | processing phase columns:      |
|           |        |           | .   IS_MAGIC                   |
|           |        |           | .   IS_GLOBAL_PREFIX           |
|           |        |           | .   IS_CHAIN_ID                |
|           |        |           | .   IS_ADDRESS                 |
|-----------|--------|-----------|--------------------------------|-------------------------|
| ∅         | ∅      |     ∅     | <!-- .   IS_Y_PARITY -->       | Not part of the message |
|           |        |           | <!-- .   IS_R -->              |                         |
|           |        |           | <!-- .   IS_S -->              |                         |
|-----------|--------|-----------|--------------------------------|-------------------------|

The idea is to carry out all steps of the above
- we do the MANDATORY PRECONDITIONS WCP CHECKS
- we do the VALIDITY WCP CHECKS

we then define

    valid_chain_id     ≡ chain_id_is_0 ∨ chain_id_is_β
    call_ec_recover    ≡ valid_chain_id ∧ valid_nonce_bound
    call_keccak_on_rlp ≡ call_ec_recover

we impose

    If call_ec_recover ≡ <false> Then AUTHORITY_RECOVERY_SUCCESS ≡ false
    If call_ec_recover ≡ <true>  Then AUTHORITY_RECOVERY_SUCCESS ≡ <prover / gnark defined>

at this point all constraints will be written assuming "If AUTHORITY_RECOVERY_SUCCESS ≡ <true>"
also the fields

    macro/AUTHORITY_NONCE
    macro/AUTHORITY_HAS_CODE
    macro/AUTHORITY_IS_DELEGATED

must be meaningful.
This could be done directly through a lookup `RLP_AUTH → HUB.account/`.
We may want to impose a sanity check constraints setting them to 0 otherwise, histoire de fixer les idées.

|---------------------------------------------|-------|------------------------------------------------------|--------------|-------------------------------------------------------|
| `RLP_AUTH` columns                          | notes | `HUB` columns                                        |     notes    |                                                       |
|---------------------------------------------|:-----:|------------------------------------------------------|:------------:|-------------------------------------------------------|
| 1                                           |       | hub.DELEGATION                                       |              |                                                       |
| rlp_auth.USER_TXN_NUMBER                    |   ✓   | hub.USER_TXN_NUMBER                                  |              |                                                       |
| rlp_auth.macro/AUTHORITY_TUPLE_INDEX        |   ✓   | hub.delegation/AUTHORITY_TUPLE_INDEX                 |              |                                                       |
| rlp_auth.macro/AUTHORITY_RECOVERY_SUCCESS   |   ✓   | hub.delegation/AUTHORITY_RECOVERY_SUCCESS            |              | defines whether to load account next or not           |
|---------------------------------------------|:-----:|------------------------------------------------------|:------------:|-------------------------------------------------------|
| rlp_auth.macro/AUTHORITY_HI                 |   ✓   | hub.delegation/AUTHORITY_HI                          |              |                                                       |
| rlp_auth.macro/AUTHORITY_LO                 |   ✓   | hub.delegation/AUTHORITY_LO                          |              |                                                       |
| rlp_auth.macro/ADDRESS_HI                   |   ✓   | hub.delegation/POTENTIALLY_NEW_DELEGATION_ADDRESS_HI |              | hub.account/DELEGATION_ADDRESS_HI_NEW will also exist |
| rlp_auth.macro/ADDRESS_LO                   |   ✓   | hub.delegation/POTENTIALLY_NEW_DELEGATION_ADDRESS_LO |              | hub.account/DELEGATION_ADDRESS_LO_NEW                 |
| rlp_auth.macro/ADDRESS_IS_ZERO_ADDRESS      |   ✓   | hub.delegation/POTENTIALLY_RESET_DELEGATION          |              |                                                       |
| rlp_auth.macro/POTENTIALLY_NEW_CODE_HASH_HI |   ✓   | hub.delegation/POTENTIALLY_NEW_CODE_HASH_HI          |              | new columns: place where to write potential updated   |
| rlp_auth.macro/POTENTIALLY_NEW_CODE_HASH_LO |   ✓   | hub.delegation/POTENTIALLY_NEW_CODE_HASH_LO          |              | code hash                                             |
|---------------------------------------------|:-----:|------------------------------------------------------|--------------|-------------------------------------------------------|
| rlp_auth.macro/AUTHORITY_NONCE              | ⟦ π ⟧ | hub.delegation/AUTHORITY_NONCE                       | justif. here | read off (potential) upcoming account/ row            |
| rlp_auth.macro/AUTHORITY_HAS_CODE           | ⟦ π ⟧ | hub.delegation/AUTHORITY_HAS_CODE                    | justif. here |                                                       |
| rlp_auth.macro/AUTHORITY_IS_DELEGATED       | ⟦ π ⟧ | hub.delegation/AUTHORITY_IS_DELEGATED                | justif. here |                                                       |
|---------------------------------------------|:-----:|------------------------------------------------------|--------------|-------------------------------------------------------|
| rlp_auth.macro/PROCEED_WITH_DELEGATION      | mixed | hub.delegation/PROCEED_WITH_DELEGATION               |              | used to decide whether to do something or not         |
|---------------------------------------------|-------|------------------------------------------------------|--------------|-------------------------------------------------------|

One way to do it in the HUB is as follows:

| perspective | AUTHORITY_RECOVERY_SUCCESS | notes                      |
|-------------|:--------------------------:|----------------------------|
| DELEGATION  |           <false>          | no address, no account row |
|-------------|----------------------------|----------------------------|
| DELEGATION  |           <true>           |                            |
| ACCOUNT     |                            | load account               |
|-------------|----------------------------|----------------------------|
| DELEGATION  |           <true>           |                            |
| ACCOUNT     |                            | load account               |
|-------------|----------------------------|----------------------------|
| DELEGATION  |           <false>          |                            |
|-------------|----------------------------|----------------------------|
| DELEGATION  |           <false>          |                            |
|-------------|----------------------------|----------------------------|
| DELEGATION  |           <true>           |                            |
| ACCOUNT     |                            | load account               |
|-------------|----------------------------|----------------------------|

This way we don't have to create this effective index (AUTHORITY_RECOVERY_SUCCESS_ACCUMULATOR).

Now that we have the currently true nonce and other information such as whether the account is delegated or not we proceed:

    authority_code_is_empty_or_already_delegated ≡ (1 - macro/AUTHORITY_HAS_CODE) ∨ macro/AUTHORITY_IS_DELEGATED
    proceed_with_delegation ≡ authority_code_is_empty_or_already_delegated ∧ nonce_agreement

    rlp_auth.macro/PROCEED_WITH_DELEGATION ≡ proceed_with_delegation

# Lookups

## Lookup to WCP

We need comparisons (ali ≡ authority list item) to verify MANDATORY PRECONDITIONS

|-----------------|--------------|----------|-----|-----------------------|
| WCP instruction | arg1         | arg2     | res | note                  |
|-----------------|--------------|----------|-----|-----------------------|
| GEQ             | ali.chain_id | 0        |     | result must be <true> |
| LT              | ali.nonce    | 1 << 64  |     | result must be <true> |
| LT              | ali.address  | 1 << 20  |     | result must be <true> |
| LT              | ali.y_parity | 1 << 8   |     | result must be <true> |
| LT              | ali.r        | 1 << 256 |     | result must be <true> |
| LT              | ali.s        | 1 << 256 |     | result must be <true> |
|-----------------|--------------|----------|-----|-----------------------|


We also need comparisons that are VALIDITY CHECK COMPARISONS (that are ALLOWED TO FAIL)

|-----------------|---------------|------------------|-------------------------|--------------------------------------------------------------------|
| WCP instruction | arg1          | arg2             | res                     | note                                                               |
|-----------------|---------------|------------------|-------------------------|--------------------------------------------------------------------|
| ISZERO          | ali.chain_id  |                  | chain_id_is_0           |                                                                    |
| EQ              | ali.chain_id  | β                | chain_id_is_β           |                                                                    |
| LT              | ali.nonce     | (2 << 64) - 1    | valid_nonce_bound       |                                                                    |
| LT              | ali.s         | secp256k1 / 2    | valid_s_bound           |                                                                    |
| EQ              | ali.nonce     | hub.acc/NONCE    | nonce_agreement         | potentially compare ali.nonce with acc/nonce + SENDER_IS_AUTHORITY |
| EQ              | ali.authority | txndata.hub/FROM | sender_is_authority     |                                                                    |
| ISZERO          | ali.address   |                  | address_is_zero_address |                                                                    |
|-----------------|---------------|------------------|-------------------------|--------------------------------------------------------------------|


## RLP-ization of authority list tuples

We need to RLP-ize the authority list. Recall that these are of the form

authority_list ≡ [ authority_item, authority_item...]
authority_item ≡ [ chain_id, address, nonce, y_parity, r, s ]

With
- chain_id ≡ integer, 32B at most, rlp-ization: 1B to 33B
- address  ≡ address, 20B exactly, rlp-ization: 21B
- nonce    ≡ integer,  8B at most, rlp-ization: 1B to 9B
- y_parity ≡ integer,  1B at most, rlp-ization: 1B or 2B
- r        ≡ integer, 32B at most, rlp-ization: 1B to 33B
- s        ≡ integer, 32B at most, rlp-ization: 1B to 33B

so that

ζ ≡ RLP( chain_id ) ∙ RLP( address ) ∙ RLP( nonce ) ∙ RLP( y_parity ) ∙ RLP( r ) ∙ RLP( s ) ∈ B_k

where k ∈ {25, ..., 122}. So that

RLP( authority_item ) ≡ RLP( ζ )
≡ <rlp_prefix> ∙ ζ

and so we must call `RLP_UTILS` for

|-----------------------|---------------|-------|
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

and for the whole list

RLP( authority_list ) ≡ <rlp_prefix> ∙ RLP( item_1 ) ∙ RLP( item_2 ) ∙ ⋯ ∙ RLP( item_n )

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
| rlp_txn.auth/PROCEED_WITH_DELEGATION      | rlp_auth.macro/PROCEED_WITH_DELEGATION      |                              |
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

## Lookup RLP_AUTH -> HUB

To transmit to transmit the access list tuple to the HUB. It also
The `HUB` should operate under the same order as the transaction has its stuff RLP-ized:
1. access list
2. authorization list

- selector: `sel ≡ rlp_txn.AUTH ∙ rlp_txn.auth/AUTHORITY_RECOVERY_SUCCESS`
- correspondence:

|---------------------------------------------|------------------------------------------------------|-------------------------------------------------------|
| RLP_AUTH columns                            | HUB columns                                          | notes                                                 |
|---------------------------------------------|------------------------------------------------------|-------------------------------------------------------|
| 1                                           | hub.auth                                             |                                                       |
| rlp_auth.USER_TXN_NUMBER                    | hub.USER_TXN_NUMBER                                  |                                                       |
| rlp_auth.macro/AUTHORITY_TUPLE_INDEX        | hub.delegation/AUTHORITY_TUPLE_INDEX                 |                                                       |
| rlp_auth.macro/PROCEED_WITH_DELEGATION      | hub.delegation/PROCEED_WITH_DELEGATION               | used to decide whether to do something or not         |
| rlp_auth.macro/ADDRESS_HI                   | hub.delegation/POTENTIALLY_NEW_DELEGATION_ADDRESS_HI | hub.account/DELEGATION_ADDRESS_HI_NEW will also exist |
| rlp_auth.macro/ADDRESS_LO                   | hub.delegation/POTENTIALLY_NEW_DELEGATION_ADDRESS_LO | hub.account/DELEGATION_ADDRESS_LO_NEW                 |
| rlp_auth.macro/ADDRESS_IS_ZERO_ADDRESS      | hub.delegation/POTENTIALLY_RESET_DELEGATION          |                                                       |
| rlp_auth.macro/POTENTIALLY_NEW_CODE_HASH_HI | hub.delegation/POTENTIALLY_NEW_CODE_HASH_HI          | new columns: place where to write potential updated   |
| rlp_auth.macro/POTENTIALLY_NEW_CODE_HASH_LO | hub.delegation/POTENTIALLY_NEW_CODE_HASH_LO          | code hash                                             |
|---------------------------------------------|------------------------------------------------------|-------------------------------------------------------|
| rlp_auth.macro/AUTHORITY_HI                 | hub.delegation/ADDRESS_HI                            |                                                       |
| rlp_auth.macro/AUTHORITY_LO                 | hub.delegation/ADDRESS_LO                            |                                                       |
| rlp_auth.macro/AUTHORITY_NONCE              | hub.delegation/NONCE                                 |                                                       |
| rlp_auth.macro/AUTHORITY_HAS_CODE           | hub.delegation/HAS_CODE                              |                                                       |
| rlp_auth.macro/AUTHORITY_IS_DELEGATED       | hub.delegation/IS_DELEGATED                          | hub.account/IS_DELEGATED_NEW will also exist          |
|---------------------------------------------|------------------------------------------------------|-------------------------------------------------------|

## Counting [SENDER ≡ AUTHORITY]

We should have the standard couple
- SENDER_IS_AUTHORITY_BIT → lives in a single rlp_auth.macro/ row, must be something like `rlp_auth.MACRO ∙ rlp_auth.macro/PROCEED_WITH_DELEGATION ∙ sender_is_authority`
- SENDER_IS_AUTHORITY_ACC → as follows
    - initialized at 0 (when `rlp_auth.USER_TRANSACTION_NUMBER` just changed)
    - is `AUTHORITY_LIST_ITEM`-constant
    - gets updated by the BIT otherwise
- SENDER_IS_AUTHORITY_TOT

## Unique sorting of transactions

We could either prove monotonicity of `rlp_auth.USER_TRANSACTION_NUMBER` (don't like it)
We could alternatively have two regimes: `rlp_auth.TXN_SUPPORTS_AUTHORITY_LIST` vs `rlp_auth.TXN_DOESNT_SUPPORT_AUTHORITY_LIST` and deal with all transaction in the present module
