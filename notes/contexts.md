# Spawning execution contexts at initialization

- if TX_SKIP ≡ 1:
	- no execution context is spawned
- if TX_INIT ≡ 1 and hubStamp = h
	- if transaction ≡ contract creation then during the TX_INIT phase there is 1 context row; that row initializes the deployment context; it is given as context number CN = 1 + h;
	- if transaction ≡ message call then during the TX_INIT phase:
		- if transaction call data = ∅ we do as with creation: there is 1 context row; that row initializes the deployment context ("root"); it is given as context number CN = 1 + h;
		- if transaction call data ≠ ∅ then we define a fictitious parent context with CN = h (which will be nonzero) which is used solely to hold the transaction call data; we also initialize as above the execution context that will be the "root context" with CN = 1 + h;
