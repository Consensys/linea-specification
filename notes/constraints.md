# Constraints

Consider an If-Then-Else constraint:

(*) If a = 0 Then P = 0 Else Q = 0 

Define a new column A. A should be a^{-1}
Subject to

- a * (1 - aA) = 0
- A * (1 - aA) = 0

Equation of pseudo inverse from Algebra
2 constraints of degree 3 + an extra column 


In equations you will have to enforce (*) like so

- a * (1 - aA) = 0
- A * (1 - aA) = 0
- a * Q + (1 - aA) * P = 0

In the end you get something of degree 4.

IF CT_i = 0 Then bla
If CT_i = 1 Then Bla'
If CT_i = 2 Then Bla''

Avoid this !!

Prefer looking ahead from the vantage point of CT_i = 0


And how do we verify a constraint ? (in the prover)

Data you want to constrain is committed to as the evaluations of polynomials over a certain FFT friendly subset of a field. Some coset of a multiplicative subgroup of the units of a field.

We have some fixed size requirements, e.G. the cosets all have size 2^22. This is realistic for say HUB and RAM.

What we prove on chain is the satisfaction of a SNARK circuit (of Plonk type) with fixed sizes that verifies a proof of our type (general huge constraint system.) It's a proof of a proof of a proof of a... (maybe 3 or 4 times). With every recursion step reduce size by a factor of sqrt(n). Vortex.

Not everything is of that circuit size.

When we verify an equation of the form

A * B + C - D * E * F * G * H + 1 = 0              (must be true on the coset, call it Dom)

We must verify that the above vanishes on the FFT domain.
It's not that the polynomials are zero, it's that their evaluations vanish on the coset.

A * B + C - D * E + 1 = Z_Dom * Q

Z_Dom = \prod_{d\in Dom} (X - d)
and
Q is the quotient of the Euclidean division of the LHS by Z_Dom.

Note: Q has degree 4 * |Dom|

FFT is needed for 2 things:
	- going from the evaluations to the coefficients
	- what we commit to is the polynomial given by its coefficients
	- to compute quotients efficiently.
		- we first do FFTs on a larger domain of size 4 * |Dom|
		- we deduce the evaluations of Q on that larger domain
		- we do inverse FFT using these evaluations to get the coefficients Q so we can commit to it.


N.B. The instruction type (1 for CREATE's, 0 for CALL's) which you inherit from the HUB is obtained not through IF statements (e.g. if ISNT = CREATE Then ...) but through "instruction decoding" i.e. by means of a lookup to a fixed reference table.

In some sense the cost of a lookup is that of 6 constraints.
