# 01.03.2024

i- BIN module BYte operation verificaiton
- several properties required to do so
- automation will take too much time
- SIGNEXTEND will e done soon, too
- similar to BYTE

- using a technique "finite quantification"
- "for all" over bounded domain can be replaced by explicit formulas
- in BIN (BYTE, SIGNEXTEND) but also SHF
- you want ot establish some intermediate property
- e.g. get the 6th BYTE and make it available through stamp constancy
- establishing in forward & backward direction (since the PIVOT byte appears "along the way fora  particular CT row", need to be propagated in both directions)
- Thus for all CT <= 6 and for all CT >= 6 etc ...

- difficulties with flag_sum's and weight_sum's as used everywhere for instruction decoding
- Z3 can deal with it but it's easiest to rewrite it for Z3 for performance gain
- would make sense to have corset semantics for dealing with binary values (negation, and, or ...)
- more readable binary semantics for corset ?
	- would be more easily interpretable by corset => whatever
	- would also be more direct for corset writers
