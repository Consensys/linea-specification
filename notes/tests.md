# Test scenarios

The instructions that require most intensive testing are:
- CALL's
- CREATE's
- SELFDESTRUCT
- SSTORE / SLOAD

Tests should focus on
- exception handling in particular opcode pricing in terms of
	- account existence / warmth
	- storage values (original, current and next)
- abort condition handling (CALL's / CREATE's)
- failure condition handling (CREATE's and CALL's to precompiles)
- rollback handling (in particular wrt deployments, warmth, refunds, SELFDESTRUCT's)
- refund tallying
	- for SSTORE instructions and SELFDESTRUCT's
	- wrt rollbacks and the MARKED_FOR_SELFDESTRUCT flag
- storage, in particular wrt
	- rollbacks
	- successive deployments
	- SELFDESTRUCT's

and their interactions.

## CALL-type instructions

**Exception scenarios:**
- stackUnderflowException
- staticContextException (only for CALL's which transfer value in a static environment)
- MXPX
- outOfGasException (but MXPX = false)
	- TO is warm ?
	- TO exists ?
	- CALL / CALLCODE transfers value

**Abort scenarios:**
- No exception but
	- CALLSTACKDEPTH = 1024
	- from.Balance < callValue

**TO addresses:**
- Non precompile
	- has code
	- doesn't have code
	- TO has been deployed several times with same or different code within the block
- Precompile (Emile's PRECOMPILE_INFO module)
	- correct gas costs
	- correct exception cases
- Address trimming is done correctly

CALL(address, ...) address µ[0] mod 2^160

## CREATE-type instructions

**Exception scenarios:**
- stackUnderflowException
- staticContextException
- MXPX
- out of gas (but MXPX = false)

**Abort scenarios:**
- No exception but
	- CALLSTACKDEPTH = 1024
	- from.Balance < callValue

**Failure condition:**
- No exception, no abort but
	- deployment address has nonzero nonce
	- deployment address has nonempty code

## SELFDESTRUCT

Main point: test how SELFDESTRUCT's interact with
- other SELFDESTRUCT's on the same address: 
- with ROLLBACK's
- STORAGE instructions (in particular deployment numbers)

**Note.** During a transaction, an address that has been marked for SELFDESTRUCT remains operational as previously in particular in terms of execution (same bytecode) and storage. It can continue to deploy other contracts, it can be CALL'ed, etc ...

**Exception scenarios:**
- stackUnderflowException
- staticContextException
- out of gas
	- TO is warm ?
	- TO exists ?
	- SELFDESTRUCT transfers value or not ?

**Refund counter:**
- Refunds are paid out only once even if a given address triggers several SELFDESTRUCTS's before the end of a transaction (TAGGED_FOR_SELFDESTRUCT)

TO address parameter:
- Address trimming is done correctly

## STORAGE

**Exception scenarios:**
- stackUnderflowException
- staticContextException (for SSTORE's)
- sstoreGasException (for SSTORE's)
- outOfGasException
	- complex pricing model depending on current value, original value, next value etc ...

**Refund counter**
- computed correctly
- discarded correctly in terms of rollbacks

Interaction with successive deployments and SELFDESTRUCT's. 
