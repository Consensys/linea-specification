# Storage data

- [Storage data](#storage-data)
  - [Storage consistency](#storage-consistency)
  - [(reordered) Storage data](#reordered-storage-data)
  - [Interaction with the state](#interaction-with-the-state)

## Storage consistency

Like for account data we use an acronym **scp** for "storage consistency permutation" (again, names may evolve.) This is a permutation of the row set of the HUB module. If X is a column in the arithmetization then scp_X is the column obtained by applying the `scp` to the rows of X. The `scp` used by the arithmetization is **some** row permutation with the following properties
1. padding-rows, after permutation, appear before non padding-rows
2. storage-rows are contiguous
3. within (reordered) storage-rows, rows are ordered as follows
  - account addresses are listed in ascending order
  - among (reordered) storage-rows with the same address storage keys are listed in ascending order
  - among (reordered) storage-rows with the same address and storage key, rows are listed in "chronological" order

**Note.** We refer the reader to the note on account consistency from the prover POV for the explanation of what constitutes a (reordered) storage-row.

## (reordered) Storage data

The Arithmetization will provide the following columns 
- binary column acp_PEEK_AT_STORAGE
  - `true` on (reordered) account rows
  - `false` on all other (reordered) rows
- binary columns FIRST_KOC, FINAL_KOC
  - The acronym `KOC` stands for "(storage) key occurrence."
  - both are false on (reordered) rows that aren't (reordered) storage-rows
  - FIRST_AOC lights up on the first (reordered) storage-row featuring some given address and some given storage key
  - FINAL_AOC lights up on the final (reordered) storage-row featuring some given address and some given storage key
  - both may be on the same row if a particular storage slot is only viewed once (e.g. a single (unreverted) SLOAD or a single (unreverted) SSTORE)
- account field columns:
  - scp_storage/ADDRESS_HI
  - scp_storage/ADDRESS_LO
  - scp_storage/KEY_HI
  - scp_storage/KEY_LO
  - scp_storage/VALUE_HI_CURR
  - scp_storage/VALUE_LO_CURR
  - scp_storage/VALUE_HI_NEXT
  - scp_storage/VALUE_LO_NEXT
  - scp_account/DEPLOYMENT_NUMBER
  - scp_account/DEPLOYMENT_NUMBER_INFTY

## Interaction with the state

The rows of interest can be filtered out by means of FIRST_KOC[i] + FINAL_KOC[i] ≠ 0 (or FIRST_KOC[i] + FINAL_KOC[i] - FIRST_KOC[i] ∙ FINAL_KOC[i] = 1).

**Original values**
- rows with original values to be extracted from the Linea state are characterized by
  - FIRST_KOC ≡ 1
  - scp_storage/DEPLOYMENT_NUMBER = 0
- the zkevm needs to trust the coherence of the following values wrt to the initial state
  - scp_storage/ADDRESS_HI
  - scp_storage/ADDRESS_LO
  - scp_storage/KEY_HI
  - scp_storage/KEY_LO
  - scp_storage/VALUE_HI_CURR
  - scp_storage/VALUE_LO_CURR

**Updated values**
- rows with final values to be committed to the Linea state are characterized by
  - FINAL_KOC ≡ 1
  - scp_storage/DEPLOYMENT_NUMBER = scp_storage/DEPLOYMENT_NUMBER_INFTY
- the state needs to update itself to reflect the following
  - scp_storage/ADDRESS_HI
  - scp_storage/ADDRESS_LO
  - scp_storage/KEY_HI
  - scp_storage/KEY_LO
  - scp_storage/VALUE_HI_NEXT
  - scp_storage/VALUE_LO_NEXT

**Account non existence**
- if an account originally existed in state and ends up, after a batch of transactions, with (final) acp_account/EXISTS_NEW = 0 then all original values in storage must be discarded, regardless of whether any storage values were used in the execution.

The above can happen with a SELFDESTRUCT (it's the only way.)

**Account redeployment**
- if an account originally existed in state and ends up after the batch of transaction with acp_account/DEPLOYMENT_NUMBER_INFTY ≠ 0 then all original values in storage must be discarded, regardless of whether any storage values were required during execution.

The above can happen for instance if an account was SELFDESTRUCT'ed in some transaction T and in a later transaction T' (same batch of tx's) redeployed (the original account was created with a CREATE2 so redeployments at the same address are possible.
