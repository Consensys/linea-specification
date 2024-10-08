<!-- Notes for a Telegram message for auditors -->

# Nearly trivial data store modules

Could be tackled in any order (modulo computational endpoints)

- SHAKIRA: trivial data store to send data to some (gnark) circuit;
- BLAKEMODEXP: trivial data store to send data to some (gnark) circuit;
- LOG_DATA / LOG_INFO: trivial data stores to prepare data to send to RLP_TXN_RCPT (the transaction receipt module);
- ROM_LEX: nearly trivial internal logic; associates every nonempty bytecode with a unique identifier (CODE_FRAGMENT_INDEX); complex relationship with the HUB;
- ROM: somewhat complex internal logic; parses bytecode / initialization code; performs jumpdestination analysis; constructs push values;
- ECDATA: data store for elliptic curve precompiles; somewhat complex internal logic (e.g. ECPAIRING) to send data to the correct external (gnark) circuit; relies heavily on other modules (MOD, WCP);
- BLOCKDATA: trivial data store for block data;
- BLOCKHASH: trivial data stores for coherence of BLOCKHASH outputs;
- GAS: trivial module; complex triggering by the HUB;

# Computational endpoints

Could be tackled in any order:

- ADD: deals with ADD, SUB; trivial;
- BIN: deals with AND, OR, XOR, NOT, BYTE and SIGNEXTEND; trivial except for BYTE and SIGNEXTEND; depends on the "binary reference table";
- EUC: deals with small euclidean divisions required by RAM operations; can call the WCP module;
- EXP: deals with computing various logarithms required in pricing the EXP opcode and the MODEXP precompile; a little involved;
- EXT: deals with ADDMOD, MULMOD; a little involved;
- MOD: deals with DIV, MOD, SDIV, SMOD; a little involved;
- MUL: deals with MUL and EXP computation; EXP is somewhat complex;
- SHF: deals with SHL, SHR, SAR; somewhat involved; depends on the "shifting reference table";
- TRM: deals with trimming addresses (e.g. converting Bytes32's from the stack to Bytes20 for BALANCE, EXTCODEXXX, CALL) and recognizing addresses of precompiles; trivial;
- WCP: deals with LT, GT, SLT, SGT, EQ, ISZERO; also deals with instructions not directly present in the EVM (LEQ ≤ and GEQ ≥); essentially trivial;

# Entry point of transactions

- RLPTXN: decodes RLP strings of transactions, partially re-encodes them to be hashed for signature verification;
- RLP_TXN_RCPT: transaction receipt module; produces the RLP for transaction receipts;
- RLP_ADDR: essentially trivial; produces the strings to be hashed and trimmed when defining deployment addresses;
- TXN_DATA: extracts relevant transaction data from the above and serves it to the HUB;

# "Users" of computational endpoints

- OOB: does all sorts of computations for various opcodes and precompiles; relies heavily on other modules (ADD, MOD, WCP)
- STP: computes upfront gas costs of CALL's and CREATE's, gas stipends for CALL's and gas provided to the child context by the parent context; relies heavily on other modules (MOD, WCP);

# Memory

- MXP: detects wildly out of bounds arguments for instructions that may trigger memory expansion; STATEFUL module (it provides e.g. the number of active words in memory for MSIZE);
- MMU: breaks complex memory instructions (MSTORE, MLOAD, MSTORE8, SHA3, RETURN, REVERT, CREATE's, COPY-instructions, ...) down into simpler custom ones;
- MMIO: executes the custom instructions prepared by the MMU; STATEFUL module;

# Hub

- HUB: main coordination module; complex;
