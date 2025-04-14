# System level transactions

There are currently two EIP's that introduce system level transactions:
- [EIP-4788: Beacon block root in the EVM](https://eips.ethereum.org/EIPS/eip-4788) (Cancun)
- [EIP-2935: Serve historical block hashes from state](https://eips.ethereum.org/EIPS/eip-2935) (Prague)

There are two further EIP's featuring system level transactions WHICH LINEA WON'T IMPLEMENT:
- [EIP-7002: Execution layer triggerable withdrawals](https://eips.ethereum.org/EIPS/eip-7002) (Prague)
- [EIP-7251: Increase the MAX_EFFECTIVE_BALANCE](https://eips.ethereum.org/EIPS/eip-7251) (Prague)

It is of note that these play out at block end, quoting @Gabriel.Trintinalia:
> these new system calls are executed after the transaction executions and are the final operations during block processing

# Approach

Both system transactions can be dealt with in two ways:
- byte code execution
- side-stepping EVM execution and just updating a particular storage slot

See [this question](https://ethereum-magicians.org/t/system-level-transactions-and-bypassing-evm-execution/23517).

Side-stepping the EVM would look as follows: for `BLOCKHASH` one has to do the following
```rust
k ≡ block_number mod 8191
𝛔[HISTORY_STORAGE_ADDRESS].setStorage(k, previous_block_hash)
```
while for the `BEACONROOT` one has to compute
```rust
k ≡ timestamp mod 8191
𝛔[BEACON_ROOTS_ADDRESS].setStorage(k, 0x00 .. 00)
```

## Special operations solution

A new execution mode of the zkEVM associated to it
- TX_SYST
- TX_SKIP
- TX_WARM
- TX_INIT
- TX_EXEC
- TX_FINL

And the TX_SYST rows are straight to the point: update the relevant storage key.

## Standard transaction solution

We _may_ introduce a new perspective
```
SYSTEM_TRANSACTION ↔ SYSTEM
```
We can have a new execution mode
- SYSTEM
- TX_SKIP
- TX_WARM
- TX_INIT
- TX_EXEC
- TX_FINL

We would be running the `setXxx` methods of the relevant SMC's. This would have wide reaching consequences
- we may need a special system transactions module
- alternatively update the TXN_DATA module
- we may need to update the RLP_TXN module to feature call data for special transactions
- we may need an alternative SYSTEM_TRANSACTION_DATA module containing parameters and call data (and e.g. used to do a full copy of txn_call_data initially
- we may have to modify the functioning of certain opcodes (e.g. `TIMESTAMP`) for the `BEACONROOT` stuff

We would need to add special transactions to the TXN_DATA module or have an alternative module for system level transactions. We would also have

## Actual solution for now

We may alternatively add columns to the `PEEK_AT_TRANSACTION` perspective which is rather small to begin with.
We introduce a new column `IS_FIRST_IN_BLOCK` in the `TXN_DATA` module. It lights up precisely when `ABS_TX_NUM = 1`.
We introduce the following columns in the HUB, too:

```rust
transaction/IS_FIRST_IN_BLOCK
transaction/L1_TIMESTAMP_MOD_8191
transaction/BEACON_ROOT_HI
transaction/BEACON_ROOT_LO
transaction/BLOCK_NUMBER_MOD_8191
transaction/PREV_BLOCK_HASH_HI
transaction/PREV_BLOCK_HASH_LO
```

We introduce a new module `TXN_SYSTEM` that will contain the data required to deal with both EIP's.
In the `TX_SKIP` and `TX_INIT` sections we do things like previously but we also distinguish between whether `transaction/IS_FIRST_IN_BLOCK ≡ 1` or not

## BLOCKHASH opcode when the state knows it, too

We could add a storage-row to (unexceptional and in range) `BLOCKHASH` opcodes. This would have the following benefit
- the output of `BLOCKHASH` would provably be the same from one conflation to another

**Note.** This would require some further checks which can be carried out in the `BLOCKHASH` module:
- argument_in_range ≡ [NUMBER - 256 ≤ ARG < NUMBER]
- argument_post_prague_hardfork ≡ [ARG ≥ constants/LINEA_PRAGUE_HARDFORK_BLOCK_NUMBER]

⇒ block_hash.CHECK_BLOCKHASH_AGAINST_STATE ≡ argument_in_range ∧ argument_post_prague_hardfork

And this bit would be handed down to the HUB which would load a STORAGE row accordingly.
Alternatively we would leave the BLOCKHASH module as is an introduce a MISC row and define a simple OOB_INST_BLOCKHASH instruction.
The issue being that the OOB doesn't know the current block NUMBER.
Though the OOB could learn it from the BTC module (as for the BLOCK_HASH module) from the REL_BLOCK_NUMBER column.
