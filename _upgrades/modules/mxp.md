# MXP module redesign

let LMMS = 256^4 (linea max memory size)

| INST           | CN  | OFFSET_1 | OFFSET_2 | SIZE_1 | SIZE_2 | DEPLOYING | RES | MXPX | GAS_MXP | LIN_COST | QUAD_COST | 
| :------------- | --: | -------: | -------: | -----: | -----: | -----: | --: | ---: | ------: | ------:  | ------:   | 
| MSIZE          |     | ∅        | ∅        | ∅      | ∅      |       |     | ∅    | ∅       | ∅        | ∅         | 
| MLOAD          |     |          | ∅        | ∅      | ∅      |       | ∅   |      |         | ∅        |           |          - compare SIZE_1 against LMMS
|                |     |          |          |        |        |       |     |      |         |          |           |          - if SIZE_1 < LMMS then compute memory expansion
| MSTORE         |     |          | ∅        | ∅      | ∅      |       | ∅   |      |         | ∅        |           | 
| MSTORE8        |     |          | ∅        | ∅      | ∅      |       | ∅   |      |         | ∅        |           | 
| CREATE         |     |          | ∅        |        | ∅      |       | ∅   |      |         | EIP-3860 |           | 
| CREATE2        |     |          | ∅        |        | ∅      |       | ∅   |      |         |          |           | 
| RETURN         |     |          | ∅        |        | ∅      | T      | ∅   |      |         |         |           | 
| RETURN         |     |          | ∅        |        | ∅      | F      | ∅   |      |         | ∅        |           | 
| REVERT         |     |          | ∅        |        | ∅      |       | ∅   |      |         | ∅        |           | 
| LOG-type       |     |          | ∅        |        | ∅      |       | ∅   |      |         | ∅        |           | 
| SHA3           |     |          | ∅        |        | ∅      |       | ∅   |      |         | ∅        |           | 
| CALLDATACOPY   |     |          | ∅        |        | ∅      |       | ∅   |      |         | ∅        |           | 
| RETURNDATACOPY |     |          | ∅        |        | ∅      |       | ∅   |      |         | ∅        |           | 
| CODECOPY       |     |          | ∅        |        | ∅      |       | ∅   |      |         | ∅        |           | 
| EXTCODECOPY    |     |          | ∅        |        | ∅      |       | ∅   |      |         | ∅        |           | 
| MCOPY          |     |          |          |        | ∅      |       | ∅   |      |         | ∅        |           | 
| CALL-type      |     |          |          |        |        |        | ∅   |      |         | ∅        |           | 
| :------------- | --: | -------: | -------: | -----: | -----: | -----: | --: | ---: | ------: | ------:  | ------:   | 
|                |     |          |          |        |        |        |     |      |         |          |           | 
  

