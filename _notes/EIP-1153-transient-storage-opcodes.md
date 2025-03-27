# Tasks

## Transient perspective and columns

- `PEEK_AT_TRANSIENT ≡ TRN`
    - it can only be on during `TX_EXEC`
- transient columns
    ```rust
    transient/ADDRESS_HI
    transient/ADDRESS_LO
    transient/STORAGE_KEY_HI
    transient/STORAGE_KEY_LO
    transient/VALUE_HI
    transient/VALUE_LO
    transient/VALUE_HI_NEW
    transient/VALUE_LO_NEW
    ```
- macros
    ```rust
    sameTransientStorageValue[ relof ]
    undoTransientStorageValueUpdate[ relof_undo, relof_do ]
    ```

## Instruction handling

- updating the storage family
    - flags, including staticFlag
    - decoded flags
- processing
    - acceptable exceptions
    - exceptions:
        - SUX
        - OOGX
            ```rust
            STACK
            ```
        - STATICX (TSTORE only)
            ```rust
            STACK
            CONTEXT
            ```
        - unexceptional WILL_REVERT
            ```rust
            STACK
            CONTEXT
            TRANSIENT // doing
            TRANSIENT // undoing
            ```
        - unexceptional WONT_REVERT
            ```rust
            STACK
            CONTEXT
            TRANSIENT // doing
            ```
    - starting with `STATICX` we check whether the context is static
    - as soon as unexceptional we also retrieve the `context/ACCOUNT_ADDRESS`
    - just as with `SLOAD` we don't print anything on the stack unless the instruction is unexceptional
    - contrary to `SSTORE` / `SLOAD` we don't have to read storage to price it, in particular we don't need to retrieve transient storage data and play with warmth
    - if `CN_WILL_REVERT` we require two rows for `TSTORE`

## Consistency arguments

- permutation according to
```rust
(
    // order imposing columns
    + transient/PEEK_AT_TRANSIENT,
    + transient/ABSOLUTE_TRANSACTION_NUMBER,
    + transient/ADDRESS_HI,
    + transient/ADDRESS_LO,
    + transient/STORAGE_KEY_HI,
    + transient/STORAGE_KEY_LO,
    + transient/DOM_STAMP,
    - transient/SUB_STAMP,
    // along for the ride
    transient/VALUE_HI,
    transient/VALUE_LO,
    transient/VALUE_HI_NEW,
    transient/VALUE_LO_NEW,
)
```
- extraneous columns
```rust
// tcp ≡ transient consistency permutation
tcp_FIRST_IN_TXN
tcp_AGAIN_IN_TXN
// no ``tcp_FINAL_IN_TXN'' column required
```
- constraints
    - standard constraints for FIRST/AGAIN
    - consistency is trivial: FIRST you have zero, when when meeting an [ADDRESS,STORAGE_KEY] pair AGAIN you get the previously updated value
