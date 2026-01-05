# `RLP_ADDR`

Likely a change: we may ask this module, which already hashes stuff, to hash for us the "code" of a delegated account, i.e. the 23 byte string

    `0x ef 00 00 <delegated_address>`

