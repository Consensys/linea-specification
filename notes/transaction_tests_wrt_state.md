Assert at the very beginning
- tx.nonce is an 8 byte integer
- tx.nonce == account.Nonce (sender, pre anything)
- initial balance (sender, pre anything)
- tx.nonce's are in order over various transactions emanating from a single sender
	- this is about the sequencer
- scenario:
	- one transaction deploys some SC
	- a later transaction in the block calls it (directly, to == deployed address)
	- one tx makes some address SELFDESTRUCT
	- a later tx targets directly the SELFDESTRUCT'ed account
- REQUIRES_EVM_EXECUTION: boolean which is only false in the following scenarios
	- message call and to address has empty byte code (i.e. pure transfer)
	- deployment transaction whose initialization code is empty

Test that these are as advertised is happening in the hub module.

Test for type 0, 1, 2 tx's.
