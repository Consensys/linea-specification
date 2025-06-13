# Notes

## columns

- make the number of columns named constants for input/result/tmp

## Beta phase

- when the transaction provides a CHAIN_ID we must compare it to the one in the BTC module
    - either through a direct lookup _if_ the transaction provides a CHAIN_ID
        - this requires a nonzeroness test for the CHAIN_ID
        - you can have a bit TRANSACTION_PROVIDES_CHAIN_ID which amounts to [CHAIN_ID ≠ 0] and is used to trigger a BTC lookup
    - or by sending it to TXN_DATA and letting TXN_DATA send it to BTC


## LOG_INFO / LOG_DATA / RLP_TXNRCPT

Separate issue, see [issue 188](https://github.com/Consensys/linea-specification/issues/188)

## Table

Transposer tableau transitions + checkmarks (✓)
Optionnel: avoir une
    - `possible_phase_transition_0`
    - `possible_phase_transition_1`
    - `possible_phase_transition_2`
    - `possible_phase_transition_3`
    - `possible_phase_transition_4`
    - et leur somme

# RLP_UTILS

## INTEGER instruction

- harmonization
    - have the same semantics for the ``prefix'' i.e. either always shifted or never shifted.
    - same for the ``left shifted input'' output
