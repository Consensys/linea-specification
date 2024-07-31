- [Dealing with CALL's to precompiles](#dealing-with-calls-to-precompiles)
	- [HUB columns sent to PRECOMPILE\_INFO](#hub-columns-sent-to-precompile_info)
	- [🔥 ECRECOVER 🔥](#-ecrecover-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction)
		- [Details](#details)
	- [🔥 SHA2-256 🔥](#-sha2-256-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-1)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-1)
		- [Details](#details-1)
	- [🔥 RIPEMD-160 🔥](#-ripemd-160-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-2)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-2)
		- [Details](#details-2)
	- [🔥 IDENTITY 🔥](#-identity-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-3)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-3)
		- [Details](#details-3)
	- [🔥 MODEXP 🔥](#-modexp-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-4)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-4)
		- [Details](#details-4)
	- [🔥 ECADD 🔥](#-ecadd-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-5)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-5)
		- [Details](#details-5)
	- [🔥 ECMUL 🔥](#-ecmul-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-6)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-6)
		- [Details](#details-6)
	- [🔥 ECPAIRING 🔥](#-ecpairing-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-7)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-7)
		- [Details](#details-7)
	- [🔥 BLAKE2f 🔥](#-blake2f-)
		- [HUB ⇆ PRECOMPILE\_INFO interaction](#hub--precompile_info-interaction-8)
		- [HUB ⇆ MMU interaction](#hub--mmu-interaction-8)
		- [Details](#details-8)


# Dealing with CALL's to precompiles

## HUB columns sent to PRECOMPILE_INFO

- ADDR_LO
- GAS_STIPEND      (GS)
- GAS_RETURNED     (GR)
- CALLDATASIZE     (CDS)
- RETURNDATASIZE   (RDS)
- SUCCESS
- TOUCHES_RAM
- PROVIDES_RETURNDATA

**Note** Below we mention the RETURN_AT_CAPACITY (R@C) value: it is the last argument to any CALL-type instruction.

## 🔥 ECRECOVER 🔥


### HUB ⇆ PRECOMPILE_INFO interaction

- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- TOUCHES_RAM $\\,\\,=\\,\\,$ 0
	- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0
	- RDS $\\,\\,=\\,\\,$ 0
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- TOUCHES_RAM $\\,\\,=\\,\\,$ 0
		- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0
		- RDS $\\,\\,=\\,\\,$ 0
	We don't need to provide data: the data will be all zeros due to padding and ECRECOVER will be unable to recover a public key.
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- TOUCHES_RAM $\\,\\,=\\,\\,$ 1
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ RDS = 0
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ RDS = 32


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{dataExtractionRamToExo}$
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ 
			- $\texttt{copyResultsFromExoToRam}$
			- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
			- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ CDS _padded to 128_ bytes $\big]$ from RAM to the EC_DATA module
2. $\texttt{copyResultsFromExoToRam}$ must copy all 32 result bytes to a fictitious context's RAM
3. $\texttt{moveRamToRam}$ must copy _up to_ 32 bytes from the ficitious context's RAM to the current context's RAM


## 🔥 SHA2-256 🔥


### HUB ⇆ PRECOMPILE_INFO interaction

- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
- TOUCHES_RAM $\\,\\,=\\,\\,$ SUCCESS
- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ SUCCESS
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ RDS $\\,\\,=\\,\\,$ 0
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ RDS $\\,\\,=\\,\\,$ 32


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{writeKnownValueToRam}$ (wherein we write SHA2-256(∅) to fictitious RAM)
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{dataExtractionRamToExo}$
		- $\texttt{copyResultsFromExoToRam}$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{writeKnownValueToRam}$ must write SHA2-256(∅) to a fictitious context's RAM
2. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ CDS _unpadded_ bytes $\big]$ from RAM to the SHA2-256_DATA module
3. $\texttt{copyResultsFromExoToRam}$ must copy all RDS = 32 result bytes from SHA2-256_INFO to a fictitious context's RAM
4. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ from the ficitious context's RAM to the current context's RAM

## 🔥 RIPEMD-160 🔥


(virtually identitcal with [SHA2-256](#sha2-256))

### HUB ⇆ PRECOMPILE_INFO interaction

- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
- TOUCHES_RAM $\\,\\,=\\,\\,$ SUCCESS
- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ SUCCESS
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ RDS $\\,\\,=\\,\\,$ 0
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ RDS $\\,\\,=\\,\\,$ 32


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{writeKnownValueToRam}$ (wherein we write RIPEMD-160(∅) to fictitious RAM)
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{dataExtractionRamToExo}$
		- $\texttt{copyResultsFromExoToRam}$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$

### Details

1. $\texttt{writeKnownValueToRam}$ must write RIPEMD-160(∅) to a fictitious context's RAM
2. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ CDS _unpadded_ bytes $\big]$ from RAM to the RIPEMD-160_DATA module
3. $\texttt{copyResultsFromExoToRam}$ must copy all RDS = 32 result bytes to a fictitious context's RAM
4. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ bytes from the ficitious context's RAM to the current context's RAM


## 🔥 IDENTITY 🔥

### HUB ⇆ PRECOMPILE_INFO interaction

- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 1  $\iff$  (SUCCESS $\\,\\,=\\,\\,$ 1  $\\,\\,\wedge\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0)
- TOUCHES_RAM = PROVIDES_RETURNDATA
- RDS = SUCCESS * CDS


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\texttt{moveRamToRam}$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{moveRamToRam}$ must transfer $\big[$ CDS _unpadded_ bytes $\big]$ to a fictitious context's RAM
2. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ bytes from the fictitious context's RAM to current RAM


## 🔥 MODEXP 🔥

### HUB ⇆ PRECOMPILE_INFO interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
	- $g_r$ $\\,\\,=\\,\\,$ 200
	- RDS $\\,\\,=\\,\\,$ 0
	- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0

Some explanation: Given that the extracted data will be 0-padded the first 96 bytes of it are all 0 so that $\ell_B = \ell_E = \ell_M = 0$ and the output is has size 0 (it's the empty byte slice ()).

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- RDS $\\,\\,=\\,\\,$ 0
		- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- RDS $\\,\\,=\\,\\,$ $\ell_M$
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ RDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ RDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 1
	- $g_r$	$\\,\\,\longleftarrow\\,\\,$ requires access to RAM for $\ell_B$, $\ell_E$, $\ell_M$ and the 32 leading bytes of E
	- $\ell_M$	$\\,\\,\longleftarrow\\,\\,$ requires access to RAM


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\texttt{dataExtractionRamToExo}$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{copyResultsFromExoToRam}$ (all $\ell_M$ = RDS bytes)
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ 1632 _padded_ bytes $\big]$ from RAM to the MODEXP_DATA module comprising
   - (32 + 32 + 32) bytes + (4096 + 4096 + 4096) bits from RAM
   - i.e. (2 + 2 + 2) + (32 + 32 + 32) = 102 limbs of 16 byte integers;
   - allows access to $\ell_B$, $\ell_E$, $\ell_M$ (these are the first 6 limbs of the data)
   - $B$, $E$ and $M$ (contained in the following 96 or less limbs of data)
   - the leading 32 bytes of E
2. $\texttt{copyResultsFromExoToRam}$ must copy all $\ell_M$ = RDS result bytes to a fictitious context's RAM
3. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ bytes from the ficitious context's RAM to the current context's RAM


## 🔥 ECADD 🔥

### HUB ⇆ PRECOMPILE_INFO interaction

- TOUCHES_RAM $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  $\big[$ TOUCHES_RAM $\\,\\,=\\,\\,1 \big]$ $\\,\\,\wedge\\,\\, \big[x, \\,\\, y \in C_1\big]$
- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ SUCCESS
- RDS $\\,\\,=\\,\\,$ 64 * SUCCESS


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\texttt{dataExtractionRamToExo}$ (we write to the EC_DATA module)
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{copyResultsFromExoToRam}$ (64 bytes <=> 4 limbs)
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ 128 _padded_ bytes $\big]$ from current RAM to EC_DATA module
2. $\texttt{copyResultsFromExoToRam}$ must copy all RDS = 64 result bytes to a fictitious context's RAM
3. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ bytes from the ficitious context's RAM to the current context's RAM


## 🔥 ECMUL 🔥


(virtually the same as [ECADD](#ecadd))

### HUB ⇆ PRECOMPILE_INFO interaction

- TOUCHES_RAM $\\,\\,=\\,\\,$ 1  $\iff$  GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$
- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  $\big[$ TOUCHES_RAM $\\,\\,=\\,\\,1 \big]$ $\\,\\,\wedge\\,\\, \big[ x \in C_1\big]$
- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ SUCCESS
- RDS $\\,\\,=\\,\\,$ 64 * SUCCESS


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\texttt{dataExtractionRamToExo}$ (we write to the EC_DATA module)
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{copyResultsFromExoToRam}$ (64 bytes <=> 4 limbs)
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ 96 _padded_ bytes $\big]$ from current RAM to EC_DATA module
2. $\texttt{copyResultsFromExoToRam}$ must copy all RDS = 64 result bytes to a fictitious context's RAM
3. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ bytes from the ficitious context's RAM to the current context's RAM


## 🔥 ECPAIRING 🔥


(similar to [ECADD](#ecadd))

### HUB ⇆ PRECOMPILE_INFO interaction

- TOUCHES_RAM $\\,\\,=\\,\\,$ 1  $\iff$  [ CDS $\\,\\, \equiv 0 \mod 192$ ] $\\,\\,\wedge\\,\\,$ [ GAS_STIPEND $\\,\\,\geq\\,\\,$ $g_r$ ]
- $192\cdot k\\,\\,=\\,\\,$ CDS where $k$ is imported from the EC_DATA module
- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  $\big[$ TOUCHES_RAM $\\,\\,=\\,\\,1 \big]$ $\\,\\,\wedge\\,\\, \big[ x_{1}, \dots, x_{k} \in C_1\big]$ $\\,\\,\wedge\\,\\, \big[ y_{1}, \dots, y_{k} \in G_2\big]$
- PROVIDES_RETURNDATA $\\,\\,=\\,\\,$ SUCCESS
- RDS $\\,\\,=\\,\\,$ 32 * SUCCESS

**Note.** TOUCHES_RAM = 1 also when CDS = 0 (and gas is sufficient.) Indeed in that case the pairing succedes and outputs 1. There will thus be some known data to fill out in a fictitious contex's RAM.


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{writeKnownValueToRam}$ (wherein we write $\texttt{0x00...0001 }\in\mathbb{B}_{32}$ to fictitious RAM)
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ CDS $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{dataExtractionRamToExo}$ (we write to the EC_DATA module)
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
			- $\texttt{copyResultsFromExoToRam}$ (32 bytes <=> 2 limbs)
			- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
			- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ CDS _unpadded_ bytes $\big]$ from current RAM to EC_DATA module
2. $\texttt{copyResultsFromExoToRam}$ must copy all RDS = 32 result bytes to a fictitious context's RAM
3. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ bytes from the ficitious context's RAM to the current context's RAM


## 🔥 BLAKE2f 🔥


### HUB ⇆ PRECOMPILE_INFO interaction

- TOUCHES_RAM $\\,\\,=\\,\\,$ 1  $\iff$  [ CDS $\\,\\,=\\,\\,$ 213 ]
- SUCCESS $\\,\\,=\\,\\,$ 1  $\iff$  [ TOUCHES_RAM $\\,\\,=\\,\\,$ 1 ] $\\,\\,\wedge\\,\\,$ [ $f \in \\{ 0, 1\\}$ ] $\\,\\,\wedge\\,\\,$ [ STIPEND $\\,\\,\geq\\,\\, r$ ]
- PROVIDES_RETURNDATA = SUCCESS
- **Note.** $f$ and $r$ will be provided in the module that collects the 213 bytes of RAM data.


### HUB ⇆ MMU interaction

- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _RAM noop_
- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ TOUCHES_RAM $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
	- $\texttt{dataExtractionRamToExo}$ (we write to some BLAKE2f_DATA module)
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
	- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ SUCCESS $\\,\\,=\\,\\,$ 1 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$
		- $\texttt{copyResultsFromExoToRam}$ (64 bytes <=> 4 limbs)
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,=\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ _that's it_
		- $\textcolor{GoldenRod}{\text{If}}\\,\\,$ R@C $\\,\\,\neq\\,\\,$ 0 $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ $\texttt{moveRamToRam}$


### Details

1. $\texttt{dataExtractionRamToExo}$ must copy $\big[$ 213 _unpadded_ bytes $\big]$ from current RAM to BLAKE2f_DATA module (which also contains the result if applicable)
2. $\texttt{copyResultsFromExoToRam}$ must copy all RDS = 32 result bytes to a fictitious context's RAM
3. $\texttt{moveRamToRam}$ must copy $\min\\{$ RDS, R@C $\\}$ bytes from the ficitious context's RAM to the current context's RAM

| INDEX | LIMB	| PARAMS |
|-------|-------|--------|
|  0	|  ...	|   r    |
|  1	|  ...	|   f  	 |
|  2	|  ...	|   0  	 |
| ...	|  ...	|  ...   |
| 13	|  ...	|   0  	 |

N.B. 14 * 16 = 213 so there will be 14 data limbs in the BLAKE2f_DATA module per BLAKE2f call

<!-- IF    <->  $\textcolor{GoldenRod}{\text{If}}\\,\\,$ -->
<!-- THEN  <->  $\\,\\,\textcolor{ForestGreen}{\text{Then}}\\,\\,$ -->
<!-- tilde <-> \\,\\, -->
