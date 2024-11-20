# Account and storage management in the zkevm from the prover POV

The zkevm is able to prove internal consistency for account fields and storage values touched / read in a batch of transactions. In so doing it is able to identify when an account (or a storage key/value pair) is touched for the **first time** and when an account (or a storage value/key pair) is touched for the **last time** in the execution of said batch of transactions. Identifying these special "first" and "final" interactions with Linea state allows us extract the required state data and update it accordingly. This identification happens in the "permuted domain" where access to the same account or storage key are listed contiguously and in chronological order.

- [Account and storage management in the zkevm from the prover POV](#account-and-storage-management-in-the-zkevm-from-the-prover-pov)
- [Account Data](#account-data)
  - [Account consistency permutation](#account-consistency-permutation)
  - [(reordered) Account data](#reordered-account-data)
  - [Interaction with the state](#interaction-with-the-state)
  - [Account existence](#account-existence)

# Account Data

## Account consistency permutation

We use the acronym **acp** for "account consistency permutation" (the names may evolve.) This is a permutation of the row set of the HUB module. If X is a column in the arithmetization then acp_X is the column obtained by applying the `acp` to the rows of X. The `acp` used by the arithmetization is **some** row permutation with the following properties
1. padding-rows, after permutation, appear before non padding-rows
2. account-rows are contiguous
3. within (reordered) account-rows, rows are ordered as follows
  - account addresses are listed in "ascending" order
  - among (reordered) account-rows with the same address, rows are listed in chronological order

**Note.** The standard, non permuted trace has **exclusive binary columns** PEEK_AT_ACCOUNT, PEEK_AT_CONTEXT, PEEK_AT_MISCELLANEOUS, PEEK_AT_STACK, PEEK_AT_STORAGE, PEEK_AT_TRANSACTION. Rows where PEEK_AT_XXX ≡ 1 are labelled XXX-rows. This is what we mean by account-rows, storage-rows, etc ... Similarly a **reordered account-row** is one where acp_PEEK_AT_ACCOUNT ≡ 1.

**Note.** The arithmetization uses multiplexed columns. Thus the same underlying, physical column X (or register), may, on some row i contain a value X[i], which according to whether we are on an account-row, context-row, etc ... will have a different name in the arithmetization (e.g. account/BALANCE[i] or context/CFI[i] or misc/MXP_OOGX[i] or storage/KEY_LO[i] etc ...) and, accordingly, a completely different interpretation.

## (reordered) Account data

The Arithmetization will provide the following columns 
- binary column acp_PEEK_AT_ACCOUNT
  - `true` on (reordered) account rows
  - `false` on all other (reordered) rows
- binary columns FIRST_AOC, FINAL_AOC
  - The acronym `AOC` stands for "account occurrence."
  - both are false on (reordred) rows that aren't (reordered) account-rows
  - FIRST_AOC lights up on the first (reordered) account-row featuring some given address
  - FINAL_AOC lights up on the final (reordered) account-row featuring some given address
  - both may be on the same row if a particular account is only viewed once (e.g. successful simple transfer)
- account field columns:
  - acp_account/ADDRESS_HI
  - acp_account/ADDRESS_LO
  - acp_account/CODE_HASH_HI
  - acp_account/CODE_HASH_LO
  - acp_account/CODE_HASH_HI_NEW
  - acp_account/CODE_HASH_LO_NEW
  - acp_account/NONCE
  - acp_account/NONCE_NEW
  - acp_account/CODE_SIZE
  - acp_account/CODE_SIZE_NEW
  - acp_account/BALANCE
  - acp_account/BALANCE_NEW

We also mention the two following rows that are of no use to the account side of things but will be important when it comes to storage (and byte code.)
- acp_account/DEPLOYMENT_NUMBER
- acp_account/DEPLOYMENT_NUMBER_INFTY

## Interaction with the state

The rows of interest can be filtered out by means of FIRST_AOC[i] + FINAL_AOC[i] ≠ 0 (or FIRST_AOC[i] + FINAL_AOC[i] - FIRST_AOC[i] ∙ FINAL_AOC[i] = 1).

**Original values**
- rows with original values are characterized by FIRST_AOC ≡ 1; the zkevm needs to trust the coherence of the following values wrt to the initial state
  - acp_account/ADDRESS_HI
  - acp_account/ADDRESS_LO
  - acp_account/CODE_HASH_HI
  - acp_account/CODE_HASH_LO
  - acp_account/CODE_SIZE
  - acp_account/NONCE
  - acp_account/BALANCE

**Updated values**
- rows with updated values are characterized by FINAL_AOC ≡ 1; the state needs to update itself to reflect the following
  - acp_account/ADDRESS_HI
  - acp_account/ADDRESS_LO
  - acp_account/CODE_HASH_HI_NEW
  - acp_account/CODE_HASH_LO_NEW
  - acp_account/CODE_SIZE_NEW
  - acp_account/NONCE_NEW
  - acp_account/BALANCE_NEW

## Account existence

**Note.** The zkevm already has to compute the following binary value
- account/EXISTS
- account/EXISTS_NEW

These are bits that equal 1 if the account **exists**. Recall that the account associated with a particular address $a$ is said not to exist in the state $\sigma$ (and $\sigma[a] = \varnothing$) if
- it has zero nonce i.e. $\sigma[a]_\text{n} = 0$
- it has zero balance i.e. $\sigma[a]_\text{b} = 0$
- it has empty code i.e. $\sigma[a]_\text{c} = \texttt{KECCAK}\big((\\;)\big)$

In all other cases the account is deemed to exist. If desirable we can include these bits in the permutation argument and also send them to the prover.

We could include them in the permutation argument and provide you with
- acp_account/EXISTS
- acp_account/EXISTS_NEW

to help the prover distinguish between accounts that the zkevm expects to find in the state of Linea vs. those that are, say, created during a transaction and don't really exist in the state.
