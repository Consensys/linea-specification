# Smart contract byte code

- [Smart contract byte code](#smart-contract-byte-code)
  - [Accessing byte code from Linea state](#accessing-byte-code-from-linea-state)
  - [Committing byte code to the Linea state](#committing-byte-code-to-the-linea-state)
  - [Notes on addressing columns from different modules](#notes-on-addressing-columns-from-different-modules)

## Accessing byte code from Linea state

The byte code of an account **which exists in the Linea state** may be required to be loaded if
- the address pointing to the account can be found among account rows of the HUB
- the underlying account **exists** and has **nonempty bytecode**
- the byte code is actually accessed either through
  - execution (target of a message call transaction or (STATIC/DELEGATE)CALL(CODE)'ed during transaction execution)
  - code copy (target of a EXTCODECOPY)

**Note.** If code is being CODECOPY'd the underlying account must already be executing, so the first bullet point was previously true.

In either of these circumstances the ROMLEX module will have a reference to
- ADDRESS_HI, ADDRESS_LO, DEPLOYMENT_NUMBER = 0, DEPLOYMENT_STATUS = 0

## Committing byte code to the Linea state

Byte code of an account with address _a_ may either
- assuming it existed in Linea state:
  - continue to exist if both
    - hub.account/DEPLOYMENT_NUMBER_INFTY = 0
    - (final) hub.acp_account/EXISTS_NEW = 1
  - be erased if either
    - hub_account/DEPLOYMENT_NUMBER_INFTY ≠ 0
    - (final) hub.acp_account/EXISTS_NEW = 0
- be introduced
  - hub.account/DEPLOYMENT_NUMBER_INFTY ≠ 0
  - (final) hub.acp_account/EXISTS_NEW = 1
  - (final) hub.acp_account/CODE_SIZE_NEW ≠ 0
  - then the code can be copied from ROM using the CFI associated with the ROMLEX values
    - rom.CFI ← romlex.CFI
	  - gives access to the pairs [INDEX, LIMB] of byte code limbs
    - romlex.CFI ← [ romlex.ADDRESS_HI, romlex.ADDRESS_LO, romlex.DEPLOYMENT_NUMBER ]
    - romlex.ADDRESS_HI ← hub.acp_account/ADDRESS_HI
    - romlex.ADDRESS_LO ← hub.acp_account/ADDRESS_LO
    - romlex.DEPLOYMENT_NUMBER ← hub.account/DEPLOYMENT_NUMBER_INFTY

## Notes on addressing columns from different modules

To disambiguate column names that may occur in several modules we use the following notation `module.COLUMN` to talk unambiguously about column `COLUMN` in the module called `module`. We remind the reader that we also have special notation for multiplexing columns whereby (e.g. in the HUB) we may speak of a column belonging to the perspective e.g. account with name e.g. BALANCE and address it as `account/BALANCE`. If this column interacts with columns from other modules we may apply both conventions and speak say of column `hub.stack/STACK_ITEM_VALUE_HI_4` to speak of the column `STACK_ITEM_VALUE_HI_4` belonging to the `stack` perspective of the `hub` module.
