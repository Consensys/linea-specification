# Deviations from the EVM

This list is likely incomplete and will evolve. This is as it stands currently:
- we don't deal with transactions whose TO address is a precompile
- we don't deal with transactions that violate transaction validity:
    - insufficient balance (for cumulative gas cost + transfer value)
    - wrong nonce (txNonce != accNonce)
- we don't deal with arbitrary calls to MODEXP: such calls are capped at 4096 bit values of E, B and M;
