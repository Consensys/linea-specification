The bug happens when a smart contract `A` performs a **self call** that will end in **failure** and will later **revert**. The nature of the bug is that we don't properly deal with the account's **balance** on the final "warmth undoing" row. In what follows we describe the difference between the **self call** and **foreign call** ways in which the

$$\texttt{scenario/CALL\_SMC\_FAILURE\_WILL\_REVERT}$$

scenario will play out.

## The foreign address call case

Consider two smart contracts `S` and `T` and assume that `S` performs a `CALL` to `T`. Assume furthermore that this call will trigger the aforementioned call scenario (failure, will revert.) The sequence of account-rows in the associated `CallSection` will be

| row   | addr | BAL    | BAL'   | relevant operation           | time                | DOM                | SUB        |
|-------|------|--------|--------|------------------------------|---------------------|--------------------|------------|
| j + 1 | S    | bS     | bS - v | bal -= value                 | now, 1st            | τ ∙ h + 1          |            |
| j + 2 | T    | bT     | bT + v | bal += value, WRM <turn on>  | now, 2nd            | τ ∙ h + 2          |            |
| j + 3 | S    | bS - v | bS     | BAL <undo [1]>               | child FAILURE, 2nd  | τ ∙ ρ_chld + ε_rev | τ ∙ h +  3 |
| j + 4 | T    | bT + v | bT [*] | BAL <undo [2]>               | child FAILURE, 1st  | τ ∙ ρ_chld + ε_rev | τ ∙ h + 4  |
| j + 5 | T    | bT [*] | bT     | WRM <undo [2]>, BAL from [4] | curr REVERTS, "now" | τ ∙ ρ_curr + ε_rev | τ ∙ h + 5  |

This works well as in the permuted domain one will find

| row | addr | BAL    | BAL'   | relevant operation           | time                | DOM                | SUB       |
|:---:|------|--------|--------|------------------------------|---------------------|--------------------|-----------|
| ... | S    | bS     | bS - v | bal -= value                 | now, 1st            | τ ∙ h + 1          |           |
|  ⋮  | S    | ...    | ...    | ...                          | ...                 | ...                |           |
| ... | S    | bS - v | bS     | BAL <undo [1]>               | child FAILURE, 2nd  | τ ∙ ρ_chld + ε_rev | τ ∙ h + 3 |
|     |      |        |        |                              |                     |                    |           |
|  ⋮  | ...  | ...    | ...    | ...                          | ...                 | ...                |           |
|     |      |        |        |                              |                     |                    |           |
| ... | T    | bT     | bT + v | bal += value, WRM <turn on>  | now, 2nd            | τ ∙ h + 2          |           |
|  ⋮  | T    | ...    | ...    | ...                          | ...                 | ...                |           |
| ... | T    | bT + v | bT [*] | BAL <undo [2]>               | child FAILURE, 1st  | τ ∙ ρ_chld + ε_rev | τ ∙ h + 4 |
|  ⋮  | T    | ...    | ...    | ...                          | ...                 | ...                |           |
| ... | T    | bT [*] | bT     | WRM <undo [2]>, BAL from [4] | curr REVERTS, "now" | τ ∙ ρ_curr + ε_rev | τ ∙ h + 5 |


## The foreign address call case

Consider now a smart contract `A` that performs a self-call. Assume furthermore that this call will trigger the aforementioned call scenario (failure, will revert.) The sequence of account-rows in the associated `CallSection` will be

| row   | addr | BAL    | BAL'       | relevant operation                    | time                | DOM                | SUB       |
|-------|------|--------|------------|---------------------------------------|---------------------|--------------------|-----------|
| j + 1 | A    | bA     | bA - v     | BAL -= value                          | now, 1st            | τ ∙ h + 1          |           |
| j + 2 | A    | bA - v | bA         | BAL += value, WRM <turn on> (useless) | now, 2nd            | τ ∙ h + 2          |           |
| j + 3 | A    | bA - v | bA         | BAL <undo [1]>                        | child FAILURE, 2nd  | τ ∙ ρ_chld + ε_rev | τ ∙ h + 3 |
| j + 4 | A    | bA     | bA - v [*] | BAL <undo [2]>                        | child FAILURE, 1st  | τ ∙ ρ_chld + ε_rev | τ ∙ h + 4 |
| j + 5 | A    | bA [*] | bA         | WRM <undo [2]>, BAL from [2]          | curr REVERTS, "now" | τ ∙ ρ_curr + ε_rev | τ ∙ h + 5 |
|       |      |        |            |                                       |                     |                    |           |
|       |      |        |            |                                       |                     |                    |           |

This won't work as the balance of the final row, the "with BAL from [2]" part, clashes

| row | addr | BAL        | BAL'       | relevant operation                    | time                | DOM                | SUB       |
|-----|------|------------|------------|---------------------------------------|---------------------|--------------------|-----------|
| ... | A    | bA         | bA - v     | BAL -= value                          | now, 1st            | τ ∙ h + 1          |           |
| ... | A    | bA - v     | bA         | BAL += value, WRM <turn on> (useless) | now, 2nd            | τ ∙ h + 2          |           |
| ... | ...  | ...        | ...        | ...                                   | ...                 | ...                |           |
| ... | A    | bA - v     | bA - v [*] | BAL <undo [2]>                        | child FAILURE, 1st  | τ ∙ ρ_chld + ε_rev | τ ∙ h + 4 |
| ... | A    | bA         | bA         | BAL <undo [1]>                        | child FAILURE, 2nd  | τ ∙ ρ_chld + ε_rev | τ ∙ h + 3 |
| ... | ...  | ...        | ...        | ...                                   | ...                 | ...                |           |
| ... | A    | bA - v [*] | bA - v     | WRM <undo [2]>, BAL from [2]          | curr REVERTS, "now" | τ ∙ ρ_curr + ε_rev | τ ∙ h + 5 |

This breaks consistency as one would expect to find bA in the final row. Indeed one would expect to find `bA` rather than `bA - v`.
