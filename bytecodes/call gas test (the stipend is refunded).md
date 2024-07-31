# Tests around CALL's and gas

In all tests below we provide the current context with `0x01` Wei ("off-camera".)

## The Gas stipend is recovered by the caller

We prewarm the target address through an EXTCODEHASH.
The CALL tries to pay `0xff` Wei so the CALL is aborted.
The resulting address still doesn't exist as witnessed by the EXTCODEHASH returning 0.

```rust
GAS          // costs 2
PUSH1 0xad   // costs 3
EXTCODEHASH  // warms 0xad up
             // should cost 2600
             // should return 0 (0xad doesn't exist in the state)
PUSH1 0      // return data size
PUSH1 0      // return data offset
PUSH1 0      // call data size
PUSH1 0      // call data offset
PUSH1 0xff   // value
PUSH1 0xad   // address
PUSH2 0xffff // gas
             // total cost = 2 + 3 + 2600 + 7 * 3 = 2626
	         // 23626 gas (21000 + 2626)
CALL         // 100 (warm access) + 9000 (transfer) + 25000 (new account)
             // upfront cost = 34100
	         // callee would get gas stipend --- are we reimbursed of 2300 ? costs should then be 31800
	         // (a) either 23626 + 34100 = 57726
	         // (b) either 23626 + (34100 - 2300) = 55426
             //
	         // RESULTS: option (b) (as expected :D)
PUSH1 0xad   // costs 3
EXTCODEHASH  // 0xad is already warm (for two "reasons") so the cost is 100
             // the output should be 0 still.
```

## Same deal but no pre-warming

Since the CALL tries to pay `0xff` Wei the CALL is aborted.
The target address `0xad` is cold at the time of the CALL.
The resulting address still doesn't exist as witnessed by the EXTCODEHASH returning 0 but is now warm.

```rust
PUSH1 0      // return data size
PUSH1 0      // return data offset
PUSH1 0      // call data size
PUSH1 0      // call data offset
PUSH1 0xff   // value
PUSH1 0xad   // address
PUSH2 0xffff // gas
             // total cost = 7 * 3 = 21
	         // 21021 gas (21000 + 21)
CALL         // 2600 (cold access) + 9000 (transfer) + 25000 (new account)
             // upfront cost = 36600
	         // callee would get gas stipend --- are we reimbursed of 2300 ? costs should then be 34300
	         // total cost = 21021 + (36600 - 2300) = 55321
PUSH1 0xad   // costs 3
EXTCODEHASH  // 0xad is already warm (for two "reasons") so the cost is 100
             // the output should be 0 still.
```

## The target of a successful (value transfering) CALL now exists as witnessed by its EXTCODEHASH and BALANCE 

The CALL tries to pay `0x01` Wei so the CALL isn't aborted.
We transfer **some** value to a nonexistent account (which thus starts existing.) 
The second EXTCODEHASH will thus return `KEC(( ))` (and cost 100 Gas.)

```rust
GAS          // costs 2
PUSH1 0xad   // costs 3
EXTCODEHASH  // warms 0xad up (and should return 0 as 0xad doesn't even exist)
             // should cost 2600
SELFBALANCE  // expected: 0xff
PUSH1 0      // return data size
PUSH1 0      // return data offset
PUSH1 0      // call data size
PUSH1 0      // call data offset
PUSH1 0x01   // value
PUSH1 0xad   // address
PUSH2 0xffff // gas
             // total cost = 2 + 3 + 2600 + 7 * 3 = 2626
	         // 23626 gas (21000 + 2626)
CALL         // 100 (warm access) + 9000 (transfer) + 25000 (new account)
             // upfront cost = 34100
	         // callee would get gas stipend --- are we reimbursed of 2300 ? costs should then be 31800
	         // total cost = 23626 + (34100 - 2300) = 55426
SELFBALANCE  // expected: 0xfe
PUSH1 0xad   // costs 3
BALANCE      // warm so cost is 100
             // the output should be 1
PUSH1 0xad   // costs 3
EXTCODEHASH  // 0xad is already warm (for two "reasons") so the cost is 100
             // the output should be KEC(( )) now (account has nonzero balance of 1 Wei)
```

## The target of a successful (value transferring) CALL doesn't exist as witnessed by its EXTCODEHASH and BALANCE 

The CALL tries to pay `0x00` Wei so the CALL isn't aborted.
We transfer **no** value to a nonexistent account (which thus starts existing.) 
The second EXTCODEHASH will thus return `KEC(( ))` (and cost 100 Gas.)

```rust
GAS          // costs 2
PUSH1 0xad   // costs 3
EXTCODEHASH  // warms 0xad up (and should return 0 as 0xad doesn't even exist)
             // should cost 2600
SELFBALANCE  // expected: 0xff
PUSH1 0      // return data size
PUSH1 0      // return data offset
PUSH1 0      // call data size
PUSH1 0      // call data offset
PUSH1 0      // value
PUSH1 0xad   // address
PUSH2 0xffff // gas
             // total cost = 2 + 3 + 2600 + 7 * 3 = 2626
	         // 23626 gas (21000 + 2626)
CALL         // 100 (warm access) + 9000 (transfer) + 25000 (new account)
             // upfront cost = 34100
	         // callee would get gas stipend --- are we reimbursed of 2300 ? costs should then be 31800
	         // total cost = 23626 + (34100 - 2300) = 55426
SELFBALANCE  // expected: 0xff
PUSH1 0xad   // costs 3
BALANCE      // warm so cost is 100
             // the output should be 0
PUSH1 0xad   // costs 3
EXTCODEHASH  // 0xad is already warm (for two "reasons") so the cost is 100
             // the output should be 0 (still)
```
