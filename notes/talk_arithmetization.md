# zkEVM

# Arithmetization

# Techniques

- arithmetic mismatch
- size proofs
- comparisons
- dominant / subordinate stamp technique
- reordering arguments
- lex. ordering techniques
- perspectives
- RAM instructions
- sporadic gas checks

# Intricacies of the EVM

- padding (zero padding)
- EXTCODECOPY / EXTCODEHASH / EXTCODESIZE
- trimming (ADDRESS)
- deployment number / status 
    - CREATE2 / CREATE / SELFDESTRUCT / deployment failure
	- several pieces of code with a given address
	- updating storage (invisible update in case of SELFDESTRUCT) 
- warmth, prewarming
- RLP everywhere
- size issues ("type system")
	- stack items must be small
	- byte decomposition of data flowing into the zkEVM
	- tx rlp + ROM + storage
- precompiles (magic values appearing in RAM)
