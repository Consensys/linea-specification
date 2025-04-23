# Tasks

## Approach

We implement a completely new opcode `BLOBBASEFEE`.
This instruction will raise the `BLC` instruction family flag.
The implementation will be trivial:
- the `HUB` module simply refers to the `BLOCK_DATA` module for the value
- the `BLOCK_DATA` module contains a constant value with zero high part
