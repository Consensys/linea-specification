# Exception profiles

The present note is a record of the way exceptions may arise and be dealt with on an opcode per opcode basis.

## Exceptions

Our zkEVM knows the following exceptions with associated stack columns:
- OPCX: invalidOpCodeException:
- SUX: stack underflow exception: stack underflow exception
- SOX: stack overflow exception
- MXPX: memory expansion exception (a subcase of the out of gas exception)
- OOGX: out of gas exception
- RDCX: RETURNDATACOPY exception
- JUMPX: invalid JUMP exception
- STATICX: static context exception 
- SSTOREX: SSTORE minimum gas exception
- ICPX: invalid code prefix exception (can only manifest for deployments)
- MAXCSX: max code size exception (can only manifest for deployments)

## Exception profiles

### Profile 1 

The following instructions trigger exceptions in the following order:

1. SUX
2. OOGX

These instructions are
```bash
ADD, SUB,
DIV, SDIV, MOD, SMOD,
ADDMOD, MULMOD,
MUL, EXP,
LT, GT, SLT, SGT, EQ, ISZERO,
AND, OR, XOR, NOT, BYTE, SIGNEXTEND,
SHL, SHR, SAR,
BALANCE, EXTCODESIZE, EXTCODEHASH,
CALLDATALOAD, SLOAD,
BLOCKHASH,
POP,
SWAP1-SWAP16,
```

### Profile 2 

1. SOX
2. OOGX

```bash
ORIGIN, CALLVALUE, GASPRICE, COINBASE, TIMESTAMP, NUMBER, PREVRANDAO, GASLIMIT, CHAINID, BASEFEE,
ADDRESS, CALLDATASIZE, CALLER, RETURNDATASIZE,
PC, MSIZE, GAS,
SELFBALANCE, CODESIZE,
PUSH0-PUSH32, 
```

### Profile 3 

1. SUX
2. MXPX
3. OOGX

These instructions are:
```bash
SHA3, 
CALLDATACOPY, CODECOPY, EXTCODECOPY,
MLOAD, MSTORE, MSTORE8,
CALLCODE, DELEGATECALL, STATICCALL,
REVERT
```

Add to that
```bash
RETURN // when NOT in a deployment context
```

### Special profile: invalid byte

1. OPCX

```bash
INVALID and all bytes that aren't opcodes 
```

### Special profile: STATIC_RAM 

1. SUX
2. STATICX
3. MXPX
4. OOGX

```bash
LOG0-LOG4, CREATE, CREATE2, CALL
```

### Special profile: DUP

1. SUX
2. SOX
3. OOGX

These instructions are:
```bash
DUP1-DUP16
```

### Special profile: JUMPs 

1. SUX
2. JUMPX
3. OOGX

These instructions are:
```bash
JUMP, JUMPI
```

### Special profile: RETURNDATACOPY 

1. SUX
2. RDCX
3. MXPX
4. OOGX

```bash
RETURNDATACOPY
```

### Special profile: SSTORE

1. SUX
2. STATICX
3. SSTOREX
4. OOGX

```bash
SSTORE
```

### Special profile: JUMPDEST

1. OOGX

```bash
JUMPDEST
```

### Special profile: code deployment

1. SUX
2. MAXCSX
3. MXPX
4. OOGX
5. ICPX

```bash
RETURN // in a deployment context
```

**Note.** STOP
