What follows are some lookup arguments that we will have to introduce post July 11.

- [Transaction data fields justification](#transaction-data-fields-justification)
  - [✨ TX\_RLP ↪ TX\_DATA ✨](#-tx_rlp--tx_data-)
    - [Purpose](#purpose)
    - [Lookup](#lookup)
  - [✨ TX\_DATA ↪ TX\_RLP ✨](#-tx_data--tx_rlp-)
    - [Purpose](#purpose-1)
    - [Data duplication](#data-duplication)
    - [Purpose](#purpose-2)
- [Transaction init code justification](#transaction-init-code-justification)
  - [✨ TX\_DATA ↪ ROM ✨](#-tx_data--rom-)
    - [Purpose](#purpose-3)
    - [Lookup](#lookup-1)
  - [✨ ROM ↪ TX\_RLP ✨](#-rom--tx_rlp-)
    - [Purpose](#purpose-4)
    - [Lookup](#lookup-2)
- [Deployment / CREATE / CREATE2 address justification](#deployment--create--create2-address-justification)
  - [✨ HUB ↪ ADDR\_RLP ✨](#-hub--addr_rlp-)
    - [Purpose](#purpose-5)
    - [Lookup](#lookup-3)
- [Signature justification](#signature-justification)
  - [✨ TX\_DATA signature verification ✨](#-tx_data-signature-verification-)
    - [Purpose](#purpose-6)
- [Prewarmed addresses justification](#prewarmed-addresses-justification)
  - [Purpose](#purpose-7)
  - [✨ HUB ↪ TX\_RLP ✨](#-hub--tx_rlp-)
  - [✨ TX\_RLP ↪ HUB ✨](#-tx_rlp--hub-)
- [Prewarmed \[address, storage keys\] pairs justification](#prewarmed-address-storage-keys-pairs-justification)
  - [Purpose](#purpose-8)
  - [✨ HUB ↪ TX\_RLP ✨](#-hub--tx_rlp--1)
  - [✨ TX\_RLP ↪ HUB ✨](#-tx_rlp--hub--1)
- [Some consequences](#some-consequences)


# Transaction data fields justification

## ✨ TX_RLP ↪ TX_DATA ✨

### Purpose

We need to make sure that (1) all transactions are dealt with, (2) no phantom transactions are carried out and (3) the data written in the TX_DATA module coincides with that encoded in the RLP. These 3 tasks aren't all done with the present lookup, rather through a bidirectional lookup arguments. 

### Lookup

We perform the following lookup:
- tx_rlp.ABS_TX_NUM ↪ tx_data.ABS_TX_NUM. 

**Note.** The above makes sure of the first point: all transactions are accounted for.

## ✨ TX_DATA ↪ TX_RLP ✨

### Purpose

The above took care of point (1). What comes now takes care of points (2) and (3): data coherence and absence of phantom transactions.

### Data duplication

In order to do a single lookup we stack the data from the TX_DATA module (which was designed to occupy a single row per transaction) vertically, too.
- we duplicate the relevant values of TX_DATA as many times as required by the transaction type
- we introduce a PHASE# column to
- we introduce a VAL_HI / VAL_LO column pair into which we extract the value associated with the PHASE#
  - TX_TYPE
  - NONCE
  - IS_DEP
  - (1 - IS_DEP) * [ TO_HI, TO_LO ]
  - VALUE
  - EFFECTIVE_GAS_PRICE (for type 0 & 1)
  - MAX_FEE (for type 2)
  - MAX_PRIORITY_FEE (for type 2)
  - DATASIZE
  - DATACOST
  - NUM_PREWARM_ADDR (for type 1 & 2)
  - NUM_PREWARM_KEYS (for type 1 & 2)
  - SIGNATURE fields

**Note.** This will allow us to perform the requisite computations (sufficient gas + for type 2 computation of the effective gas price).

### Purpose

The lookup will take as inputs the following:
- source columns
  - tx_data.ABS_TX_NUM
  - tx_data.PHASE#
  - tx_data.VAL_HI
  - tx_data.VAL_LO
- target columns
  - tx_rlp.ABS_TX_NUM
  - $\sum_i i\cdot$ tx_rlp.PHASE[i] 
  - tx_rlp.VAL_HI
  - tx_rlp.VAL_LO

**Note.** This requires us to introduce two new data columns tx_rlp.VAL_HI, tx_rlp.VAL_LO which will be used to store values that appear in the inputs / ... columns of TX_RLP.

# Transaction init code justification

## ✨ TX_DATA ↪ ROM ✨

### Purpose

We need to make sure that the call data of deployment transactions (which is the associated initialization code) is in the ROM. As such we will need an extra bit in the ROM to signal the bytecodes that are transaction provided initialization codes and a column that indicates the transaction number.

### Lookup

We perform the following lookup:
- selector: IS_DEP * [DATASIZE != 0]
- source columns:
  - tx_data.ABS_TX_NUM
  - tx_data.TO_HI
  - tx_data.TO_LO
  - tx_data.DATASIZE
- target columns:
  - rom.ABS_TX_NUM
  - rom.ADDRESS_HI
  - rom.ADDRESS_LO
  - rom.CODESIZE


## ✨ ROM ↪ TX_RLP ✨

### Purpose

We need to make sure that the call data of deployment transactions (which is the associated initialization code) is in the ROM. As such we will need:
- an extra bit, say IS_TX_INIT_CODE, in the ROM to signal transaction provided initialization code
- a column indicating the transaction number (along rows where the IS_TX_INIT_CODE = 1.)

### Lookup

We perform the following lookup:
- selector: IS_TX_INIT_CODE
- source columns:
  - rom.ABS_TX_NUM
  - rom.LIMB
  - rom.INDEX
  - rom.IS_TX_INIT_CODE
- target columns (where we set φ = tx_rlp.PHASE_[DATA] the phase flag for the data phase):
  - tx_rlp.ABS_TX_NUM * φ
  - tx_rlp.LIMB * φ
  - tx_rlp.INDEX * φ
  - φ 

# Deployment / CREATE / CREATE2 address justification

## ✨ HUB ↪ ADDR_RLP ✨

### Purpose

We need to justify the TO_ADDRESS for deployments: either deployment transactions or CREATE instructions.  or so and select the non-updated nonce, creator address and created address values which are found on neighboring rows. This lookup will justify

### Lookup

- selector: we use PEEK_ACCOUNT * IS_DEP
- source columns:
  - yet to be properly selected, must take a look at the hub spec
- target columns:
  - addr_rlp.CREATOR_ADDR_HI
  - addr_:w
  rlp.CREATOR_ADDR_LO
  - addr_rlp.NONCE
  - addr_rlp.CREATED_ADDR_HI
  - addr_rlp.CREATED_ADDR_LO
  - addr_rlp.SALT_HI
  - addr_rlp.SALT_LO
  - addr_rlp.INST
  - addr_rlp.HUB_STAMP

**Note.** The purpose of the HUB_STAMP column is to allow us to retrieve the following columns
  - kec.INITCODE_HASH_HI
  - kec.INITCODE_HASH_LO

from the KECCAK_INFO module (or whatever we will end up calling it.)

# Signature justification

## ✨ TX_DATA signature verification ✨

### Purpose

We need to make the signature fields of the transaction available for the ECDSA module. Don't know how we will do this. There is the option to just insert these values into the EC_DATA module. I don't like that solution at all.


# Prewarmed addresses justification

## Purpose

Simple bilateral lookup to prove the prewarming of all addresses for a transaction.

**Note.** We have a bit of an issue here: it is conceivable that someone would provide addresses to prewarm to a transaction that requires no EVM execution. There are two solutions to this:
- either we propagate the information (requires EVM execution or not) upwards from the HUB to the TX_DATA module and from there to the TX_RLP module; in this case we can have a transaction constant bit in the TX_RLP which we can use to select only those addresses / storage keys to include in the prewarming phase of the HUB that correspond to transactions requiring actual EVM execution
- either we modify the heartbeat to add phony PREWMARING phases for transactions requiring no EVM execution.

The first solution is the simplest. We will opt for that one 🏅.

## ✨ HUB ↪ TX_RLP ✨

- selector: PREWARM * PEEK_ACCOUNT
- source columns:
  - hub.ABS_TX_NUM
  - hub.acc/ADDR_HI
  - hub.acc/ADDR_LO
  - 1
- target columns:
  - tx_rlp.ABS_TX_NUM
  - tx_rlp.ADDR_HI
  - tx_rlp.ADDR_LO
  - tx_rlp.PHASE[ACCESS_SET]

## ✨ TX_RLP ↪ HUB ✨

- selector: tx_rlp.PHASE[ACCESS_SET] * tx_rlp.REQUIRES_EVM_EXECUTION
- source columns:
  - tx_rlp.ABS_TX_NUM
  - tx_rlp.ADDR_HI
  - tx_rlp.ADDR_LO
  - 1
- target columns (setting wa := hub.PREWARM):
  - hub.ABS_TX_NUM * wa
  - hub.acc/ADDR_HI * wa
  - hub.acc/ADDR_LO * wa
  - wa

# Prewarmed [address, storage keys] pairs justification

## Purpose

Simple bilateral lookup to prove the prewarming of all [addresses, storage key] pairs a transaction.

## ✨ HUB ↪ TX_RLP ✨

- selector: PREWARM * PEEK_STORAGE
- source columns:
  - hub.ABS_TX_NUM
  - hub.sto/ADDR_HI
  - hub.sto/ADDR_LO
  - hub.sto/SKEY_HI
  - hub.sto/SKEY_LO
  - 1
- target columns:
  - tx_rlp.ABS_TX_NUM
  - tx_rlp.ADDR_HI
  - tx_rlp.ADDR_LO
  - tx_rlp.SKEY_HI
  - tx_rlp.SKEY_LO
  - tx_rlp.PHASE[ACCESS_SET]

## ✨ TX_RLP ↪ HUB ✨

- selector: tx_rlp.PHASE[ACCESS_SET] * tx_rlp.REQUIRES_EVM_EXECUTION * [whatever selects for keys, DEPTH1 or DEPTH2 ?]
- source columns:
  - tx_rlp.ABS_TX_NUM
  - tx_rlp.ADDR_HI
  - tx_rlp.ADDR_LO
  - tx_rlp.SKEY_HI
  - tx_rlp.SKEY_LO
  - 1
- target columns (setting ws := hub.PREWARM * PEEK_STORAGE):
  - hub.ABS_TX_NUM * ws
  - hub.acc/ADDR_HI * ws
  - hub.acc/ADDR_LO * ws
  - hub.sto/SKEY_HI * ws
  - hub.sto/SKEY_LO * ws
  - ws

# Some consequences

The TX_RLP and TX_DATA modules must be augmented slightly:
- TX_DATA:
  - we need redundancy to reduce the number of lookups
  - we need a REQURIES_EVM_EXECUTION binary column (which is justified in the hub)
  - we should do the gas price computations (for Type 2 transactions) here
- TX_RLP:
  - we require a transaction-constant binary column REQUIRES_EVM_EXECUTION which is justified in TX_DATA
- ROM:
  - IS_TX_INIT_CODE
  - ABS_TX_NUM