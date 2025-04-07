Data that will emanate from the BLOCKDATA module
- TIMESTAMP
- COINBASE
- CHAINID
- NUMBER
- PREVRANDAO
- GASLIMIT
- BASEFEE


| IOMF | REL_BLOCK_NUMBER | INST       | DATA_HI | DATA_LO           |
|------|------------------|------------|---------|-------------------|
| 0    | 0                | 0          | 0       | 0                 |
|------|------------------|------------|---------|-------------------|
| 1    | 1                | TIMESTAMP  | 0       | <unix time stamp> |
| 1    | 1                | COINBASE   | 4B      | 16 B              |
| 1    | 1                | CHAINID    | 0       | <chain id>        |
| 1    | 1                | NUMBER     |         |                   |
| 1    | 1                | PREVRANDAO |         |                   |
| 1    | 1                | GASLIMIT   |         |                   |
| 1    | 1                | BASEFEE    |         |                   |
|------|------------------|------------|---------|-------------------|
| 1    | 2                | TIMESTAMP  | 0       | <unix time stamp> |
| 1    | 2                | COINBASE   | 4B      | 16 B              |
| 1    | 2                | CHAINID    |         |                   |
| 1    | 2                | NUMBER     |         |                   |
| 1    | 2                | PREVRANDAO |         |                   |
| 1    | 2                | GASLIMIT   |         |                   |
| 1    | 2                | BASEFEE    |         |                   |
|------|------------------|------------|---------|-------------------|
| 1    | 3                | TIMESTAMP  | 0       | <unix time stamp> |
| 1    | 3                | COINBASE   | 4B      | 16 B              |
| 1    | 3                | CHAINID    |         |                   |
| 1    | 3                | NUMBER     |         |                   |
| 1    | 3                | PREVRANDAO |         |                   |
| 1    | 3                | GASLIMIT   |         |                   |
| 1    | 3                | BASEFEE    |         |                   |
|------|------------------|------------|---------|-------------------|


We keep
- FIRST_ABSOLUTE_BLOCK_NUMBER
- RELATIVE_BLOCK_NUMBER
- selector ≡ Σ_b (1 - b[-1]) * b selects for the first occurrence of some value
- CT columns disappears
