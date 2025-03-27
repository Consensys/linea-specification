# Tasks

## Transient perspective and columns

- PEEK_AT_TRANSIENT ≡ TRN
    - it can only be on during TX_EXEC
- transient columns
    ```rust
    transient/ADDRESS_HI
    transient/ADDRESS_LO
    transient/VALUE_HI
    transient/VALUE_LO
    transient/VALUE_HI_NEW
    transient/VALUE_LO_NEW
    transient/STORAGE_KEY_HI
    transient/STORAGE_KEY_LO
    ```
- macros
    - sameTransientStorageValue[ relof ]
    - undoTransientStorageValueUpdate[ relof_undo, relof_done ]

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

## Consistency arguments

- permutation according to
```rust
(
    ↑ transient/PEEK_AT_TRANSIENT,
    ↑ transient/ABSOLUTE_TRANSACTION_NUMBER,
    ↑ transient/ADDRESS_HI,
    ↑ transient/ADDRESS_LO,
    ↑ transient/STORAGE_KEY_HI,
    ↑ transient/STORAGE_KEY_LO,
    ↑ transient/DOM_STAMP,
    ↓ transient/SUB_STAMP,
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
