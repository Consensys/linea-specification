# Dealing with transactions targeting precompiles

This note explains how we will overcome the current limitation whereby we explicitly exlude transactions with

    tx.to() ∈ { precompile addresses }

We should be able to do this at relatively low cost.

## `TX_SKIP_STD` and `TX_SKIP_PRC`

For simplicity we introduce two `TX_ABCD` columns which replace the one `TX_SKIP`

    TX_SKIP_STD
    TX_SKIP_PRC

and the related shorthand

    tx_skip  ≡  TX_SKIP_STD  +  TX_SKIP_PRC

Logically we require

```java
tx_skip  ⇔  tx.to().isEmpty()
                ?  tx.payload().isEmpty()
                :  tx.to().code().isEmpty();

TX_SKIP_STD  ⇔  tx.to().isEmpty()
                    ?   tx.payload().isEmpty()
                    :   tx.to().code().isEmpty()  ∧  !tx.to().isPrecompile();

TX_SKIP_PRC  ⇔  !tx.to().isEmpty()
                    ∧  tx.to().code().isEmpty()
                    ∧  tx.to().isPrecompile();
```

**Note.** `TX_SKIP_PRC` doesn't require the explicit `∧ tx.to().code().isEmpty()` condition. We include it for symmetry reasons.

**Note.** This will have to be updated for EIP-7702, likely like so:

```java
tx_skip  ⇔  tx.to().isEmpty()
                ?  tx.payload().isEmpty()
                :  tx.to().isDelegated()
                       ?  tx.to().delegate().code().isEmpty()
                       :  tx.to().code().isEmpty();

TX_SKIP_STD  ⇔  tx.to().isEmpty()
                    ?  tx.payload().isEmpty()
                    :  tx.to().isDelegated()
                           ?  tx.to().delegate().code().isEmpty()  ∧  !tx.to().delegate().isPrecompile()
                           :  tx.to().code().isEmpty()  ∧  !tx.to().isPrecompile();

TX_SKIP_PRC  ⇔  !tx.to().isEmpty()
                ∧  tx.to().isDelegated()
                           ?  tx.to().delegate().code().isEmpty()  ∧  tx.to().delegate().isPrecompile()
                           :  tx.to().code().isEmpty()  ∧  tx.to().isPrecompile();
```

**Note.** `TX_SKIP_PRC` doesn't require the explicit `∧ (rel. acc.).code().isEmpty()` condition. We include it for symmetry reasons.

## `TX_SKIP_PRC`

We do the following for `TX_SKIP_PRC`:

```rust
PEEK_AT_TRANSACTION  // i + 0:
PEEK_AT_ACCOUNT      // i + 1: sender: subtract value
PEEK_AT_ACCOUNT      // i + 2: sender: convert and subtract gas, depends on scenario/PRC_SUCCESS etc ...
PEEK_AT_ACCOUNT      // i + 3: recipient: add value
PEEK_AT_ACCOUNT      // i + 4: coinbase: convert and add gas
PEEK_AT_MISC         // i + 5: transfer of call data to RAM
PEEK_AT_SCENARIO     // i + 6:
/**
* precompile + scenario specific rows; we set:
*
* precompileScenarioRowForTxSkip(
*     anchor_row = i,
*     rel_offset = \relOf,
*     callee_address = tx.to(),
*     callee_gas = tx.gas_initially_avaialble(),
*     type_safe_cds = tx.payload().size(),
* )
*
* precompile processing as elsewhere
*/
PEEK_AT_CONTEXT
// empty context (should already be included in the flag sums)
// actually: we have to be careful: we may not want to update the 0 context ...
```

We thus require a variation on `precompileScenarioRow[i + ω]`, i.e.

```rust
precompileScenarioRowForTxSkip[i + ω] ≡

   PEEK_AT_SCENARIO                 [i + ω] = 1
   scenario/PRC_sum                 [i + ω] = transaction/TO_ADDRESS_LO [i]
   scenario/PRC_failure             [i + ω] = <tbd>
   scenario/PRC_SUCCESS_WILL_REVERT [i + ω] = 0
   scenario/PRC_SUCCESS_WONT_REVERT [i + ω] = <tbd>
   scenario/PRC_CALLER_GAS          [i + ω] = 0
   scenario/PRC_CALLEE_GAS          [i + ω] = transaction/GAS_INITIALLY_AVAILABLE [i]
   scenario/PRC_RETURN_GAS          [i + ω] = <tbd>
   scenario/PRC_CDO                 [i + ω] = 0
   scenario/PRC_CDS                 [i + ω] = transaction/CALL_DATA_SIZE [i]
   scenario/PRC_R@O                 [i + ω] = 0
   scenario/PRC_R@C                 [i + ω] = 0
```

We still require
```rust
flag_sum[2/2] = nsr[2/2]
```
We do not need to specify NSR since it's only required in `TX_EXEC`.
