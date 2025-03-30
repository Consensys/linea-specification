# MXP module redesign

MXP module to become like the OOB module.
5 types of MXP instructions
- TYPE 1
    - MSIZE
- TYPE 2
    - MLOAD
    - MSTORE
- TYPE 3
    - MSTORE8
- TYPE 4
- TYPE 5
    - CALL

new instructions:
- MCOPY

Will be of the same type as the other COPY instructions (CALLDATACOPY, (EXT)CODECOPY, RETURNDATACOPY)
