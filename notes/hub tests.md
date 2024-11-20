## CN_NEW purpose

CN_NEW: represents the context number of the context wherein the next instruction of the will be executed. Whether the execution context changes or remains the same ... depends on the CONTEXT_MAY_CHANGE flag i.e. CMC.

Recall that

```rust
XAHOY == true <=> [any exception occurs]
```
and that
```rust
CMC == true <=> XAHOY == true                                                  // 100% sure CN_NEW = CN_CALLER
                   || opCode.InstructionFamily() == InstructionFamily.HALTING  // 100% sure CN_NEW = CN_CALLER
                   || opCode.InstructionFamily() == InstructionFamily.INVALID  // 100% sure CN_NEW = CN_CALLER
                   || opCode.InstructionFamily() == InstructionFamily.CREATE
                   || opCode.InstructionFamily() == InstructionFamily.CALL

// PS: I write XAHOY == true  just for more explicit pseudo-code
```

The idea is simple
- If `CMC = false` then CN_NEW == CN automatically
- if `CMC = true` then there are three possibilities:
  - CN_NEW == CN (context _could have changed_ but ended up _not changing_)
  - CN_NEW == HUB_STAMP + 1 (when actually entering a CREATE(2) or a CALL other than to a precompile)
  - CN_NEW == CALLER_CN (when the current execution context stops executing)

## Tests

### Back to CALLER

Under any of the following scenarios one should have CN_NEW == CALLER_CN:
  - [ ] if `InstructionFamily.HALTING`
  - [ ] if `InstructionFamily.INVALID` Then CN_NEW == CALLER_CN
  - [ ] if $\textsf{XAHOY}_{i} = 1$ Then CN_NEW == CALLER_CN

### Back to SELF

Under any of the following scenarios one should have CN_NEW == CN:
- [ ] If $\textsf{CMC}_{i} = 0$ Then must equal CN
- [ ] CREATE's
  - [ ] no exception but abort
  - [ ] no exception, no abort but $\textsf{FCOND}_{i} = 1$ (deployment address already has nonzero nonce or nonempty code)
  - [ ] no exception, no abort but empty init code
- [ ] CALL's
  - [ ] no exception but abort
  - [ ] no exception, no abort but call to precompile

### Entering new context

Under any of the following scenarios one should have CN_NEW == HUB_STAMP + 1:
- CALL: no exception, no abort, to != precompile
- CREATE: no exception, no abort and non empty init code

## `EXT`-Address instructions

These tests pertain to $\texttt{EXTCODECOPY}$, $\texttt{EXTCODEHASH}$, $\texttt{EXTCODESIZE}$  instructions. We must test that
- [ ] `EXT-Address` instruction tests
  - [ ] those addresses correctly cut their address stack argument down $\mod 2^{160}$ (purpose of the $\textsf{TRM}$ module)
  - [ ] if the target address has its `DEP_STATUS == true` then 
    - [ ] $\texttt{EXTCODECOPY}$ copies 0's into RAM
    - [ ] $\texttt{EXTCODEHASH}$ returns $\color{green}\texttt{KEC}(\varnothing)$
    - [ ] $\texttt{EXTCODESIZE}$ returns 0
  - [ ] if the target address doesn't exist currently then
    - [ ] $\texttt{EXTCODECOPY}$ copies 0's into RAM
    - [ ] $\texttt{EXTCODEHASH}$ returns $\color{green}0$
    - [ ] $\texttt{EXTCODESIZE}$ returns 0
  - [ ] This must be true even if there are several successive (failed) deployments at a given address.

**Note.** If an address is 
