# Forced transactions --- arithmetization side

## RIPEMD and BLAKE2f

The arithmetization is ready to deal with both precompiles.
The only missing piece are the gnark circuits for either of these.
As such there are no spec changes required specifically with them
(outside of the **detection** of the calls to these unsupported precompiles.
The "limits" will have to be relaxed to some positive value.
The approach is thus to use the arithmetization as intended, using valid
outputs for either precompile.

## MODEXP

The arithmetization must slightly adapt
- OOB instruction:
    - the [OOB_modexp_xbs] (?) instruction interface must be enhanced to include a bit equivalent to
        ```python
        byte_sizes_are_in_range ≡ [bbs ≤ 512] ∧ [ebs ≤ 512] ∧ [mbs ≤ 512]
        ```
    - the OOB instruction processing must be modified accordingly, replacing `assert`'s with the setting of `byte_sizes_are_in_range`
    - the `byte_sizes_are_in_range` bit must be integrated in the OOB interface
    - we may require a new (Prague forced transactions exclusive) `scenario/MODEXP_invalid_xbs` bit
    - the HUB processing
- PRC processing
    - maybe best solution is to define a new scenario altogether
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
