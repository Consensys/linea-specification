## Lookup columns

There is the option to use dedicated columns for the lookups, e.g.:

| ARG_1_LO | ARG_2_LO    | RES_LO | INST  | WCP   | MOD   |
| :---:    | :---:       | :---:  | :---: | :---: | :---: |
| CDS + 31 | 32          | bla    | MOD   | 0     | 1     |
| 3000     | GAS_STIPEND | 1      | LT    | 1     | 0     |
| LM       | L_B         | 1      | LT    | 1     | 0     |

(N.B.: the high parts, which one must insert into the lookups, will always be 0)

These columns could be used to (1) simplify the layout of the lookups that are done to WCP and MOD (2) kill many of the EXPMOD related columns. The idea being that in case of a EXPMOD you produce a mosaic of results from lookups to WCP and MOD and use these values to further the compuation in the next rows.

This should allow you to kill the following columns (at least):
- MODEXP_LM_LESS_THAN_LB
- MODEXP_MAX_LM_LB_BYTES_COUNT
- MODEXP_LE_GREATER_THAN_32
- MODEXP_BIG_FRACTION (result from a DIV)
- MODEXP_NUMERATOR (remplissage à la mano)

for other reasons one should probably get rid of:
- MODEXP_E_LEADING_WORD_RELEVANT_HALF (just insert a second If in the If INDEX ==  15 Then MOD_EXP_ACC = ...)

## Making the lookups explicit

### WCP lookups:

- GAS_STIPEND <  PRECOMPILE_COST       (must be done for all precompiles)
- 0 <= STAMP_DELTA < 2**32             (must be done for all precompiles)
- EQ applied to     213 = CDS          (BLAKE2f)
- EQ applied to 192 * k = CDS          (for ECPAIRING)
- LT applied to l_M and l_B            (MODEXP specific)
- LT applied to l_E and  32            (MODEXP specific)
- LT applied to 200 and (big floor)    (MODEXP specific)

### MOD lookups

- DIV by 32 (after adding 31) of CDS
- DIV by 8  (after adding 7)  for f(x)
- DIV by 3
- DIV by 192
