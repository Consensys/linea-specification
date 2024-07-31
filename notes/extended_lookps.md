# Extended lookup discussion with Alex and Bogdan

Notes from 2023.12.20 

Github issue: https://github.com/Consensys/zkevm-monorepo/issues/1615
Extending the API for lookups: we would have to provide the source and target columns and the source / target boolean filters.
Bogdan: this may allow us to not have to recommit to the "filtered" columns.
As opposed to the pre-filtered stuff.

In practice we only mask stuff in the source.

Conditional on the target table.

Does this mean changes in Corset ?
- translation into constraints: 

Fragmenting lookups:
====================
- GOAL: getting rid of interleaved columns
	- i.e. more efficient way to get the same functionality as interleaving without doing the interleaving.
- HUB: contains little redundancy (mostly CN and HEIGHT)
- HUB: consistency of storage / account
- HUB: possibility to have extra modules (ACC, STO, ...)
- MMIO: contains some redundancy (16 times repetition of VAL_A, ...)

The need is more on the prover side.
And we can't get improvements on the HUB just by these techniques.
