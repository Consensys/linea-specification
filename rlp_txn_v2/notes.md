# Notes

## columns

- make the number of columns named constants for input/result/tmp

## Beta phase

- when the transaction provides a CHAIN_ID we must compare it to the one in the BTC module
    - either through a direct lookup _if_ the transaction provides a CHAIN_ID
        - this requires a nonzeroness test for the CHAIN_ID
        - you can have a bit TRANSACTION_PROVIDES_CHAIN_ID which amounts to [CHAIN_ID ≠ 0] and is used to trigger a BTC lookup
    - or by sending it to TXN_DATA and letting TXN_DATA send it to BTC

## Data phase

- the TXN_DATA requires now
    - rlp/NUMBER_OF_ZERO_BYTES
    - rlp/NUMBER_OF_NONZERO_BYTES
    and no longer the DATA_COST / DATA_SIZE

## LOG_INFO / LOG_DATA / RLP_TXNRCPT

Separate issue, see [issue 188](https://github.com/Consensys/linea-specification/issues/188)
