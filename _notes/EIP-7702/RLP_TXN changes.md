# `RLP_TXN` changes

## Columns

- new transaction type `TYPE_4` flag
- new `IS_ACCOUNT_DELEGATION` phase
- new `ACCOUNT_DELEGATION_DATA` perspective, with columns named `deleg/XXX`
    - have such a delegation row either at the start or end of every account delegation query in the `RLP_TXN`
    - its fields subsume in one place all relevant data for a particular account delegation, in particular
        - `deleg/DELEGATION_INDEX` (wrt to the transaction: delegation order matters and must be tracked)
        - `deleg/SIGNER_ADDRESS`
        - `deleg/SIGNER_NONCE`
        - `deleg/DELEGATION_ADDRESS`
        - potentially the signature fields for easier extraction
        - some computed bits:
            - `deleg/IS_PROPER_DELEGATION`       which is logically equivalent to `!DELEGATION_ADDRESS.equals(Address.ZERO)`
            - `deleg/SENDER_SELF_DELEGATION_BIT` which is logically equivalent to `DELEGATION_ADDRESS.equals(txn/SENDER_ADDRESS)`
        - an accumulator columnm `deleg/SENDER_SELF_DELEGATION_ACC` which accumulates `deleg/SENDER_SELF_DELEGATION_BIT`
    - at the end of all account delegations of a `TYPE_4` transaction set a field `txn/NUMBER_OF_SENDER_SELF_DELEGATION` as the final value of `deleg/SENDER_SELF_DELEGATION_ACC`

## Structure

Typically have each and every account delegation be dealt with in a constant size block à la

```
ACCOUNT_DELEGATION_BLOCK ≡ {
    deleg,
    compt,
    compt,
    ⋮
    compt,
    txn, // or not ...
}
```

NOTE. We could also not include the `txn` row.
Their purpose is to have easy access to `txn/SENDER_ADDRESS` at all times.
We may simply have linking constraints from one account delegation block to another.
Likely the best solution is to have this happen top -> down as any phase starts with a TXN row.

NOTE. The above requires the `TXN_DATA -> RLP_TXN` lookup to also provide `txn/SENDER_ADDRESS`.

## `RLP_TXN -> HUB` lookup

- we add a new lookup `RLP_TXN -> HUB` lookup for account delegation transaction phase
    - source selector : `rlp_txn.deleg/ACCOUNT_DELEGATION_DATA`
    - target filter   : none required

|-------------------------------------|-----------------------------------|
| source column                       | target column                     |
|-------------------------------------|-----------------------------------|
| 1                                   | hub.TX_DLGT                       |
| rlp_txn.USER_TRANSACTION_NUMBER     | hub.USER_TRANSACTION_NUMBER       |
| rlp_txn.deleg/DELEGATION_INDEX      | hub.acc/DELEGATION_INDEX          | // is there a better way than introducing such a column ?
|-------------------------------------|-----------------------------------|
| rlp_txn.deleg/SIGNER_ADDRESS_HI     | hub.acc/ADDRESS_HI                |
| rlp_txn.deleg/SIGNER_ADDRESS_LO     | hub.acc/ADDRESS_LO                |
| rlp_txn.corrected_nonce             | hub.acc/NONCE                     |
|-------------------------------------|-----------------------------------|
| rlp_txn.deleg/DELEGATION_ADDRESS_HI | hub.acc/DELEGATION_ADDRESS_NEW_HI |
| rlp_txn.deleg/DELEGATION_ADDRESS_LO | hub.acc/DELEGATION_ADDRESS_NEW_LO |
|-------------------------------------|-----------------------------------|
| rlp_txn.deleg/IS_PROPER_DELEGATION  | hub.acc/IS_DELEGATED_NEW          |
|-------------------------------------|-----------------------------------|

NOTE. We have used the following shorthand

    `corrected_nonce ≡ deleg/SIGNER_NONCE - deleg/SENDER_SELF_DELEGATION_BIT`

this deals with the "sender nonce lag" due to the nonce update of the sender taking place _before_ any account delegation

