# Tasks

## HUB module

- new `(3,0)-stack-pattern`
- new instruction family ? YES, for simplicity. Alternatively we could expand the `KEC` family.
- processing (assuming no `SUX`)
    - unconditionally impose `PEEK_AT_MISC[i + 1] ≡ 1` and fill the `MXP_INST`
    - we will have
    ```rust
    trigger_MXP ≡ 1
    trigger_MMU ≡ (1 - XAHOY) ∙ S1NZNOMXPX
    ```
    - `MXPX  ≡ 1` and `OOGX  ≡ 1`
    ```rust
    STACK
    MISC
    (CON) // automatic
    ```
    - `XAHOY ≡ 0` ∧ `trigger_MMU ≡ 0`
    ```rust
    STACK
    MISC
    ```
    - `XAHOY ≡ 0` ∧ `trigger_MMU ≡ 1`
    ```rust
    STACK
    MISC
    MISC // only if trigger_MMU
    ```

## MXP module

- `MCOPY` supported as of [MXP redesign #60](https://github.com/Consensys/linea-specification/issues/60)
