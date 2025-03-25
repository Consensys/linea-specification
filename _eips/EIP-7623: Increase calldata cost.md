# Notes

This EIP affects two parts of transaction processing: initialization and finalization.

## Notations

```java
long upfrontTransactionGasCost = 21_000
                            + (isDeployment ? 32_000 : 0)
                            + dataCost(payload)
                            + accessListCost(accessList)
                            + (isDeployment ? initializationCodeWordCost(payload) : 0)
                            + accountDelegationCost();

long floorTransactionCost = 21_000 + 10 * weightedTokenCount(payload);

dataCost(payload) = 4 * weightedTokenCount(payload);
weightedTokenCount(payload) = numberOfZeroBytes(payload) + 4 * numberOfNonzeroBytes(payload);
```

## Transaction validity

Transaction validity encompasses all the usual checks (nonce, balance, comparing `upfrontTransactionGasCost` to `tx.gasLimit()`, ...) and a new check:

```java
boolean validTransaction = ... // nonce, balance, ...
                            ∧ upfrontTransactionGasCost ≤ tx.gasLimit()
                            ∧ floorTransactionCost ≤ tx.gasLimit()
                            ∧ ...;
```

The initial amount of gas the root frame starts with remains the same:

```java
long gasAvailableForExecution = tx.gasLimit() - upfrontTransactionGasCost;
```

## Transaction finalization

Transaction finalization works just as previously but a floor price `floorTransactionCost` applies to the transaction. This amounts to

```java
long gasLimit = tx.gasLimit()
long gasRemaining = frame.getRemainingGas()
long effectiveRefund = min( frame.accruedRefunds(), (gasLimit - gasRemaining) / 5)

long consumedGas = max( gasLimit - gasRemaining - effectiveRefund, floorTransactionCost ) // this is new: previously just "gasLimit - gasRemaining - effectiveRefund"

senderAccount.getEndOfTransactionGasRefund( effectiveGasPrice, gasLimit, consumedGas ) // something à la "sender.balance += effectiveGasPrice * (gasLimit - consumedGas)"
```
