# Forced transactions --- arithmetization side

## RIPEMD and BLAKE2f

The arithmetization is ready to deal with both precompiles. The only missing piece are the gnark circuits for either of these. As such there are no spec changes required specifically with them (outside of the **detection** of the calls to these unsupported precompiles. The "limits" will have to be relaxed to some positive value. The approach is thus to use the arithmetization as intended, using valid outputs for either precompile.

## MODEXP

The arithmetization must adapt.

### `[OOB_INST_modexp_xbs]` instruction

The `[OOB_INST_modexp_xbs]` (?) instruction interface must be enhanced to include a bit equivalent to

```python
byte_sizes_are_in_range ≡ [bbs ≤ 512] ∧ [ebs ≤ 512] ∧ [mbs ≤ 512]
```

the OOB instruction processing must be modified accordingly, replacing `assert`'s with the setting of `byte_sizes_are_in_range` the `byte_sizes_are_in_range` bit must be integrated in the OOB interface we may require a new (Prague forced transactions exclusive) `scenario/MODEXP_invalid_xbs` bit

### Precompile processing in the HUB

maybe best solution is to define a new scenario altogether
- call it `scenario/MODEXP_UNSUPPORTED_BYTE_SIZE_PARAMETERS`
    - we set initially impose that it is orthogonal to the others
    - and `address = wgth_addr_sum` where the weighted sum has
    ```python
    wght_addr_sum = ... + 5 * (scenario/MODEXP + scenario/MODEXP_UNSUPPORTED_BYTE_SIZE_PARAMETERS)
    ```
    we then do the same processing initially, and disambiguate at the stage where we have called [OOB_modexp_xbs]:
    ```python
    scenario/MODEXP[i] = byte_sizes_are_in_range
    byte_sizes_are_in_range := misc/OOB_DATA_k[i + ?]
    ## and implicitly
    ## scenario/MODEXP_UNSUPPORTED_BYTE_SIZE_PARAMETERS[i] = 1 - byte_sizes_are_in_range
    ```

Do-over. What seems reasonable now is to have several MODEXP specific scenarios:

```python
scenario/MODEXP_SUPPORTED
scenario/MODEXP_UNSUPPORTED___FAILURE_PATENT
scenario/MODEXP_UNSUPPORTED___FAILURE_SUBTLE
scenario/MODEXP_UNSUPPORTED___SUCCESS       
```

and we enhance the `OOB_modexp_xbs` instruction so that it computes

```python
# for x = b, m, e:
[xbs >     0],
[xbs ≤   512],
[xbs ≥ LB4QP],
[xbs ≥ LB4LP],

# where
LB4QP  ≡ 2^17 # LB4QT stands "lower bound for quadratic part"
LB4LP  ≡ 2^25 # LB4LT stands "lower bound for linear    part"
```

and we set

```python
scenario/MODEXP_SUPPORTED  ≡   [bbs ≤  512]
                             ∧ [ebs ≤  512]
                             ∧ [mbs ≤  512]

scenario/MODEXP_UNSUPPORTED_PATENT_OOG  ≡   [bbs ≥ LB4QP]
                                          ∨ [mbs ≥ LB4QP]
                                          ∨ [bbs > 0] ∧ [ebs ≥ LB4LP]
                                          ∨ [mbs > 0] ∧ [ebs ≥ LB4LP]

# this corresponds to the pricing being ≥ 65M gas
┌                                                 ┐
│ + scenario/MODEXP_SUPPORTED                     │
│ + scenario/MODEXP_UNSUPPORTED___FAILURE_PATENT  │
│ + scenario/MODEXP_UNSUPPORTED___FAILURE_SUBTLE  │ = scenario/MODEXP
│ + scenario/MODEXP_UNSUPPORTED___SUCCESS         │
└                                                 ┘
```

If we are in the `scenario/modexp_unsupported` case we still have to disambiguate. We do the `[OOB_INST_modexp_pricing]` instruction and extract `ram_success` from it. We then set

```python
scenario/MODEXP_UNSUPPORTED___SUCCESS        ≡     ram_success
scenario/MODEXP_UNSUPPORTED___FAILURE_SUBTLE ≡ 1 - ram_success # sanity check
```

In the `scenario/MODEXP_UNSUPPORTED_FAILURE` scenario we stop here.
In the `scenario/MODEXP_UNSUPPORTED_SUCCESS` scenario we do
- a full copy from a `TRASH_MODEXP_RESULT_MODULE` module to a fresh RAM segment to hold return data
- we do a partial copy from that fresh RAM segment to the current ram (if [r@c ≠ 0] obviously)

## Explanation for the `LB4QP` & `LB4LP` constants and the `scenario/MODEXP_UNSUPPORTED_PATENT_OOG` setting

For memory to work as expected we cannot simply give up if the byte sizes don't satisfy the `≤ 512` condition. This means that we must still detect whether the precompile will succeed or not. For `MODEXP`, at this stage, this amounts to detecting whether we run out of gas. Thus we must still detect out of gas scenarios and, if none was detected, update RAM in agreement with the EVM. We must be careful in our gas computation, as the gas computation of `MODEXP` contains a cubic term. So explicitly computing the gas cost is out of the picture _in the general case_. Like with memory expansion costs, that features a quadratic term, we consider sufficient criteria for rejecting an unsupported MODEXP call. Given the formula for the gas price which is essentially

```python
[ ((max(bbs, mbs)/8)^2 * (1 ∨ 8*ebs) ] / 3
```

we can be assured the precompile will run out of gas if

```python
# max(bbs, mbs) ≥ μ ≡ 2^m, and we use G := 2 ^ 26 = 65 M gas
# as an upper limit for how much gas will be available in the frame
# also we use 4 rather than 3 to simplify things
(μ / 8) ^ 2 = 2 ^ [2*(m-3)] ≥ 4 * G ⇔ 2*(m-3) ≥ 28 ⇔ m ≥ 17

# ASSUMING max(bbs, mbs) ≠ 0 i.e. [bbs > 0] ∨ [mbs > 0] ≡ true
# ebs ≥ ε ≡ 2 ^ e
8 * ε ≥ 4 * G ⇔ 2 ^ [e + 3] ≥ 4 * G ⇔ e ≥ 25
```

Thus, in order to be guaranteed to be running out of gas (with a generous upper limit on the `callee_gas` of 65M) it is enough that we have any of the following

```python
- [bbs ≥ LB4QP]
- [mbs ≥ LB4QP]
- ([bbs > 0] ∨ [mbs > 0]) ∧ [ebs ≥ LB4LP]
```

As such, and as previously indicated, this is how we will discover `scenario/MODEXP_UNSUPPORTED_PATENT_OOG`.

## Fusaka `MODEXP`

Note that the above will simplify in Fusaka. We don't even have to keep scenarios such as

```python
# discard this !
scenario/MODEXP_EIP_7823_COMPLIANT
scenario/MODEXP_EIP_7823_NONCOMPLIANT
```

Indeed we will use the same (potentially simplified) `[OOB_INST_modexp_xbs]` (where 512 is replaced with 1024) instruction and just update the success / failure conditions by providing an early failure condition:

```python
eip_7823_compliant_byte_sizes ≡ [bbs ≤ 1024] ∧ [ebs ≤ 1024] ∧ [mbs ≤ 1024]
```

and we have an early failure condition for `MODEXP` (i.e. preceding pricing) which we _may or may not_ want to act upon early. If we don't we do extra computations (which in any case are rare) but keep one failure path for `MODEXP`.

## HUB detecting invalid transactions

Simple proposal: add shared columns

```rust
INVALID_TRANSACTION_BIT  ≡  INV_BIT
INVALID_TRANSACTION_ACC  ≡  INV_ACC
INVALID_TRANSACTION_TOT  ≡  INV_TOT
```

satisyfing the following constraints

```rust
INV_BIT ≡
- binary
- HUB_STAMP constant
- If HUB_STAMP.prev() ≠ HUB_STAMP and INV_BIT = <true> Then
    - stack/CALL_FLAG = <true>
    - account/IS_PRECOMPILE[???] = <true>
    - scenario/PRC_CALL_??? = <true> // the first scenario row
- PEEK_AT_SCENARIO = <true> and `scenario/precompile` = <true> Then // the second scenario row
    - INV_BIT = scenario/RIPEMD + scenario/MODEXP_UNSUPPORTED_BYTE_SIZE_PARAMETERS + scenario/BLAKE2f

INV_ACC ≡
- binary
- HUB_STAMP constant
- (vanishes on padding rows)
- If TOTL_TXN_NUMBER.next() ≠ TOTL_TXN_NUMBER Then INV_ACC.next() = <false> // resetting the accumulator
- If TOTL_TXN_NUMBER.next() = TOTL_TXN_NUMBER Then
    - If HUB_STAMP.next() ≠ HUB_STAMP Then
        - If INV_ACC = <false> Then INV_ACC.next() = INV_BIT.next()
        - If INV_ACC = <true>  Then INV_ACC.next() = <true>

INV_TOT ≡
- If TOTL_TXN_NUMBER.next() ≠ TOTL_TXN_NUMBER Then INV_TOT = INV_ACC
- INV_TOT[N] = INV_ACC[N] // final row; Note: this is useless given that the final transaction is a SYSF transaction
```

## New `MODEX_UNSUPPORTED___SUCCESS_OUTPUT_DATA` module

This module would have essentially

```go
|-----|------|------|-------|--------|----------|
|  ID | SIZE | LIMB | INDEX | nBYTES |   PHASE  |
|:---:|:----:|:----:|:-----:|:------:|:--------:|
|     |      |      |       |        | Φ_result |
|     |      |      |       |        | Φ_result |
|     |      |      |       |        | Φ_result |
|  h' |      |      |       |        | Φ_result |
|-----|------|------|-------|--------|----------|
|  h  |  371 |      |   0   |   16   | Φ_result |
|  h  |  371 |      |   1   |   16   | Φ_result |
|  h  |  371 |      |   2   |   16   | Φ_result |
|  h  |  371 |      |   3   |   16   | Φ_result |
|  h  |  371 |      |   4   |   16   | Φ_result |
|     |      |      |       |        |          |
|  ⋮  |   ⋮  |      |   ⋮   |    ⋮   |     ⋮    |
|     |      |      |       |        |          |
|  h  |  371 |      |   21  |   16   | Φ_result |
|  h  |  371 |      |   22  |   16   | Φ_result |
|  h  |  371 |      |   23  |    3   | Φ_result |
|-----|------|------|-------|--------|----------|
| h'' |      |      |       |        | Φ_result |
```

The only constraints it must satisfy are the usual:
- monotony of the ID
- ID-constancy of SIZE
- counting up the SIZE from nBYTES
- "inside" of the data nBYTES ≡ 16
- there is only one phase Φ_result as we don't harvest inputs

Come to think about it, this _could_ be integrated into the `BLAKE_MODEXP_DATA` module. Just use a new phase constant, re-use existing constraints and add a new `IS_UNSUPPORTED_SUCCESSFUL_MODEXP_RESULT` binary column. Also no ID conflict may arise. And when we discard this "feature" we can simply require `IS_UNSUPPORTED_SUCCESSFUL_MODEXP_RESULT ≡ 0`.
