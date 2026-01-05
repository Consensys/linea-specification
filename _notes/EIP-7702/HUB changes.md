# `HUB` changes

## Columns

For the account perspective:
- new `TRANSACTION_AUTHORIZATION_PHASE` / `TX_AUTH` (on the same level as `TX_WARM`, `TX_SKIP`, `TX_INIT`, `TX_EXEC`, `TX_FINL` transaction phases)
- new `PEEK_AT_AUTHORIZATION`           / `AUTH` (on the same level as `ACC`, `CON`, `MISC`, `STACK`, `STO`, `TXN` etc ...)
- new `IS_DELEGATED`                    / `IS_DELEGATED_NEW`            columns
- new `DELEGATION_ADDRESS_HI`           / `DELEGATION_ADDRESS_LO`       columns
- new `DELEGATION_ADDRESS_NEW_HI`       / `DELEGATION_ADDRESS_NEW_LO`   columns
- new `DELEGATION_CODE_HASH_HI`         / `DELEGATION_CODE_HASH_LO`     columns
- new `DELEGATION_CODE_HASH_NEW_HI`     / `DELEGATION_CODE_HASH_NEW_LO` columns
- constrain `IS_DELEGATED` to remain constant unless `TX_AUTH ≡ 1`
- every RLP_TXN row of `ACCOUNT_DELEGATION_DATA` type gives rise to exactly one `TX_AUTH` row
- every row does the expected delegation and sets `IS_DELEGATED_NEW` to `deleg/IS_DE_DELEGATION`
- every row does `acc/NONCE_NEW = 1 + acc/NONCE`
    - even the "sender self delegation" rows
- every row triggers the lookup to `TRM` and to `RLP_ADDR`
    - TRM:      for obvious reasons (initial prc recognition)
    - RLP_ADDR: in order that we may use this module to compute the `CODE_HASH_NEW`

Question:
- do we modify the code size ? or do we require new `DELEGATION_CODE_SIZE` / `DELEGATION_CODE_SIZE_NEW` columns
- how do we modify the recognition of EOA's for CALL's ?


- we add a new lookup `RLP_TXN -> HUB` lookup for account delegation transaction phase
    - source selector : `hub/TX_AUTH`
    - target filter   : none required


## The HUB's view on the `TX_AUTH` phase


We will require
```rust
// processing requires only ACC or AUTH
If TX_AUTH[i] ≡ 1 Then PEEK_AT_ACCOUNT[i] + PEEK_AT_AUTHORIZATION[i] ≡ 1

// entry constraint: you start on an account row
If TX_AUTH[i - 1] ≡ 0 ∧ TX_AUTH[i] ≡ 1 Then PEEK_AT_ACCOUNT[i] ≡ 1

// forced oscillations between ACC and AUTH
If TX_AUTH[i] ≡ 1 ∧ TX_AUTH[i + 1] ≡ 1 Then
    + PEEK_AT_ACCOUNT[i]     ∙ PEEK_AT_AUTHORIZATION[i + 1]
    + PEEK_AT_ACCOUNT[i + 1] ∙ PEEK_AT_AUTHORIZATION[i]
        ≡ 1

// ACC → AUTH always
If TX_AUTH[i] ≡ 1 ∧ PEEK_AT_ACCOUNT[i] ≡ 1 Then
    ∙ TX_AUTH[i + 1] ≡ 1
    ∙ PEEK_AT_AUTHORIZATION[i + 1] ≡ 1 // obsolete
```

The above ensures that the `TX_AUTHORIZATION` phase always happens like this:

```go
───>  ACC  ───>  AUTH  ───>
       ↑           │
       └───────────┘
```

Recall: the purpose of the `PEEK_AT_AUTHORIZATION` perspective is to serve as a vehicle between the `RLP_AUTH` and the `HUB` modules.

## `TX_INIT` and `TX_SKIP` changes

We have to use both `txn/NONCE` and `txn/NUMBER_OF_SENDER_SELF_DELEGATION` to compare it to `acc/NONCE` before raising it.

## Opcode changes

The following opcodes require an account row:

| OpCode                                   |  Affected | Notes                                                           |
|------------------------------------------|:---------:|-----------------------------------------------------------------|
| BALANCE                                  |     NO    |                                                                 |
|------------------------------------------|-----------|-----------------------------------------------------------------|
| CODESIZE, CODECOPY                       |     NO    | The only codes that get executed are those of smart contracts   |
|                                          |           | Even if these opcodes are being called after calling a dele-    |
|                                          |           | gated EOA, the underlying code belongs to a SMC and gets        |
|                                          |           | CODECOPY-ed as usual                                            |
|------------------------------------------|-----------|-----------------------------------------------------------------|
| EXTCODESIZE                              | minimally | There are some questions                                        |
| EXTCODEHASH                              | minimally |                                                                 |
| EXTCODECOPY                              |    YES    | The simplest solution is likely to have two memory operations   |
|                                          |           |                                                                 |
|                                          |           | 1. write to a fresh new context with ID = HUB_STAMP the code    |
|                                          |           | .  which is simply 0x ef 00 00 <delegated_address> which occu-  |
|                                          |           | .  pies 23 = 3 + 20 bytes                                       |
|                                          |           |                                                                 |
|                                          |           | 2. to simplify things we do this via an `MSTORE` like operation |
|                                          |           | .  with hi part: `0xef0000 << (4 * 8) + DELEGATION_ADDRESS_HI`  |
|                                          |           | .  and  lo part: `DELEGATION_ADDRESS_LO`                        |
|                                          |           | .  and TGT_OFFSET = 0                                           |
|                                          |           |                                                                 |
|                                          |           | 3. we do a `ramToRam` operation from the context with equal     |
|                                          |           | .    SRC_ID ≡ HUB_STAMP                                         |
|                                          |           | .    TGT_ID ≡ CONTEXT_NUMBER                                    |
|                                          |           | .    SRC_OFFSET = <magical_offset>                              |
|                                          |           |                                                                 |
|                                          |           |                                                                 |
|------------------------------------------|-----------|-----------------------------------------------------------------|
| CALL, CALLCODE, DELEGATECALL, STATICCALL |    YES    | Probably as soon as we are past the MXPX test we must introduce |
|                                          |           | an extra account row for the delegation. The convention ought   |
|                                          |           | to be                                                           |
|                                          |           | .   - if no delegation just repeat the modified recipient       |
|                                          |           | .   - if delegation    print the delegated account              |
|                                          |           |                                                                 |
|                                          |           | This will also have consequences for the STP pricing            |
|                                          |           | Since the STP pricing establishes, IIRC,                        |
|                                          |           |                                                                 |
|                                          |           | .     misc/STP_OOGX                                             |
|                                          |           |                                                                 |
|                                          |           | We should likely provide it with an extra bit which is logical- |
|                                          |           | ly equivalent to                                                |
|                                          |           |                                                                 |
|                                          |           | .     [recipient is delegated] ∧ [delegatee is warm]            |
|                                          |           |                                                                 |
|                                          |           | and we then add the surcharge for delegation warming automati-  |
|                                          |           | cally into the STP pricing and OOGX flag.                       |
|                                          |           |                                                                 |
|                                          |           | Undoing will also require more work as we have to undo both the |
|                                          |           | recipient (that is, μ_s[0].trim()) and delegatee warming        |
|                                          |           |                                                                 |
|                                          |           | We will also have to modify how we set the scenario, in parti-  |
|                                          |           | cular how we recognize EOA's and SMC's.                         |
|                                          |           |                                                                 |
|                                          |           | NOTE. Since account delegation to a precompile does not lead    |
|                                          |           | to precompile execution when called and a PRC itself can't      |
|                                          |           | delegate since it can't sign a transaction there may be no      |
|                                          |           | changes to scen/PRC                                             |
|                                          |           |                                                                 |
|------------------------------------------|-----------|-----------------------------------------------------------------|
| CREATE, CREATE2                          |     NO    |                                                                 |
| SELFDESTRUCT                             |     NO    | not entirely sure at this point, but looks like it's unaffected |
|------------------------------------------|-----------|-----------------------------------------------------------------|

To understand the value `magical_offset :≡ 9` given to `SRC_OFFSET`,
consider the following diagram showing how we want to populate the dummy context:

```
    <----------------- 0th limb ----------------->  <----------------- 1st limb ----------------->

                                    <dlgt addr hi>  <--------------- dlgt addr lo --------------->

                                    ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓       ↓   ↓

    00  00  00  ..  00  ef  00  00  xx  xx  xx  xx  yy  yy  yy  yy  yy  yy  yy  yy  yy  ..  yy  yy  00  00  ..
                                                                                  
    ↑   ↑   ↑   ..  ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ..  ↑   ↑
                                                                                  
    0   1   2   ..  8   9   10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  ..  30  31  32  33  ..  // offset in CN ≡ HUB_STAMP

                        ↑
                 <magical_offset>
```

## `CODE_HASH` computation for account delegations

We will need to send stuff to some hasher. It's easiest to do this for every `TX_AUTH` row. There are various options for where to do this.
One _could_ insert MISC rows between every account row. I don't like this.
One _could_ use the lookup to RLP_ADDR which we will also trigger, send the DELEGATION_ADDRESS, too, and also request the hashing of the 'code', that is the 
following 23 bytes

    `0x ef 00 00 <delegated_address>`

## Account consistency changes

I have some questions I need confirmation on
- if an EOA account self destructs (via delegate code execution) does it maintain its delegation status ? I would imagine: YES but need to make sure
- are there any interactions with deployment numbers ? likely no
- the consistency constraints are likely obvious

## new `HUB -> RLP_TXN` lookup

|-----------------------------|---------------------------------|
| source column               | target column                   |
|-----------------------------|---------------------------------|
| 1                           | rlp_txn.ACCOUNT_DELEGATION_DATA |
| hub/USER_TRANSACTION_NUMBER | rlp_txn.USER_TRANSACTION_NUMBER |
| hub.acc/DELEGATION_INDEX    | rlp_txn.deleg/DELEGATION_INDEX  | // is there a better way than introducing such a column ?
|-----------------------------|---------------------------------|

