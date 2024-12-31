- [x] first step: randomized bytecode that triggers the MXP often without producing errors along the way
- [ ] second step: randomized bytecode that contains meaningful CREATE's
- [ ] third step: same thing but CREATE's finish with nontrivial (randomized) RETURNs: this allows us to deploy nontrivial smart contracts 
- [ ] fourth step: same thing but after the successful deployment remember the deployment address (SSTORE) and later on CALL that address

# Meaningful CREATE's

- produce a function nontrivialCreate() that returns a _slice of bytes_ INIT that will be the initialization code
	- use appendOpcodeCall() many times to fill INIT, finishing on a RETURN or REVERT
- produce a function called randomBytecodeWithCreates() that will return a random bytecode
	- appending random opcode calls like previously
	- from time to time invoke the nontrivialCreate() function to produce a slice of bytes INIT
		- choose a random small offset called INITCODEOFFSET
		- take that slice of bytes INIT, chop it up into 32B chunks
		- PUSH32 a chunk, and MSTORE it starting INITCODEOFFSET
		- every new chunk is again PUSH32'd, MSTORE'd at the previous offset + 32
		- when the code has been stored in memory in its entirety we invoke appendOpcodeCall() with the following instruction:
			- OpCode  = CREATE (or CREATE2 but add some random 32B salt to it) 
			- offset1 = INITCODEOFFSET
			- size1   = |INIT| (length of the slice of bytes)
			- value   = some random small number (< 10**18)
	- rinse and repeat
		- i.e. to this several times within a single global bytecode that you produce

This will allow you to test for very cheap the coherence conditions

# Producing meaningful deployments

You can then: also tests CALL's quite cheaply if you first do something like this:
	- the final RETURN instruction that you produced above should, too, have interesting arguments
	- you can create, similiarly as above, a function called nontrivialReturn() that:
		- produces some interesting DEPLOYMENTCODE (some bytecode produced like INIT earlier)
		- sticks this DEPLOYMENTCODE into memory (of the CREATEE) with again some PUSH32's and MSTORE's
		- at the end returns that slice of bytecode
	- then you can after the CREATE(2) instruction you have the address on the stack
	- you can then use that address (maybe SSTORE it)
	- and use it in CALL's

This requires some care:
	- the nontrivialReturn must be invoked within the nontrivialCreate funtion
	- in otherwords, we should append such a nontrivialReturn to the end of the INIT code we use.

