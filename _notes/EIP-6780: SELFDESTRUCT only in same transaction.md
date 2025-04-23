# Tasks

## Approach

We can deal with this in the following way:
- add a transaction-constant binary column `account/HAS_CODE_FIRST_IN_TXN`
- the only constraints are that
    - this is binary
    - transaction-constancy in the permuted realm
```
If acp_FIRST_IN_TXN[i] ≡ 1 Then acp_HAS_CODE_FIRST_IN_TRANSACTION[i] = acp_HAS_CODE[i]
If acp_AGAIN_IN_TXN[i] ≡ 1 Then acp_HAS_CODE_FIRST_IN_TRANSACTION[i] = acp_HAS_CODE_FIRST_IN_TRANSACTION[i - 1]
```
- when processing a SELFDESTRUCT we act upon it like so:
    - If `account/HAS_CODE_FIRST_IN_TXN ≡ 0` Then
        - deleting the account at the end
            - raising the deployment number
            - erasing the balance
            - erasing the code
            - resetting the nonce
    - If `account/HAS_CODE_FIRST_IN_TXN ≡ 1` Then we apply the modified way
        - maintain the balanace if `recipient == accountAddress`
        - not deleting account at the end, i.e. maintain as is
            - the deployment number
            - the balance
            - the code
            - the nonce
- the marking system has to be amended as we only need it for accounts that can get wiped off of the state i.e. with `HAD_CODE_INITIALLY ≡ false`.
- also the **account deletion** row is only relevant if SELFDESTRUCT effectively leads to account deletion. Again, this can only happen if `HAD_CODE_INITIALLY ≡ false`.
- we should add a sanity check constraint à la
    - if `acc/HAD_CODE_INITIALLY ≡ true` Then `acc/MARKED_FOR_SELFDESTRUCT ≡ false`

> **Question.** Why only log the first recorded value of `account/HAS_CODE` ? I.e. why don't we care about the `balance` and the `nonce` or e.g. log the first recorded value of `account/EXISTS` ?

We cannot use account existence as a criterion since an account which gets deployed in a transaction may have nonzero balance prior to deployment, and would thus exist in the state. We also don't care about nonzero nonce. Indeed, for an account to be able to `SELFDESTRUCT` it must have nonempty code, which means that it was deployed at some stage and has nonzero nonce. In any case, the only criterion that matters is whether the account has code to begin with.
