- [MODEXP\_INFO and MODEXP\_DATA](#modexp_info-and-modexp_data)
  - [MODEXP\_INFO](#modexp_info)
    - [HUB data](#hub-data)
    - [MMIO data](#mmio-data)
    - [Required checks](#required-checks)
    - [Execution flow in the HUB](#execution-flow-in-the-hub)
    - [Simplification](#simplification)
  - [MODEXP\_DATA](#modexp_data)
    - [Representation](#representation)

# MODEXP_INFO and MODEXP_DATA

We currently deal with MODEXP stuff in the PREC_INFO module. We will not be doing this in the future. Here is the idea for the workflow

## MODEXP_INFO

The MODEXP_INFO module receives data from two sources:

### HUB data

(Will likely occupy cells on a scenario row)
- HUB_STAMP
- $\ell_B$ (low part only, HUB module prediction)
- $\ell_E$ (low part only, HUB module prediction)
- $\ell_M$ (low part only, HUB module prediction)
- GAS_STIPEND, GAS_LEFTOVER, MODEXP_OOGX (the last one is a bit; the first one is computed, the other ones are predicted) 
- CALL's to MODEXP expect the following


### MMIO data

- $\ell_B$ (high and low part, 32B read from memory)
- $\ell_E$ (high and low part, 32B read from memory)
- $\ell_M$ (high and low part, 32B read from memory)
- $\textsf{LEAD\\_E} \equiv \big( \textsf{LEAD\\_E\\_HI} , \textsf{LEAD\\_E\\_LO} \big)$

### Required checks

We verify the following, at transition points:
- [WCP] show strict increments of the HUB_STAMP
- [WCP] verify that $\ell_B \leq 512$ i.e. $<513$
- [WCP] verify that $\ell_E \leq 512$ i.e. $<513$
- [WCP] verify that $\ell_M \leq 512$ i.e. $<513$
- [WCP] inquire whether $\ell_E \leq 32$ (i.e. $<33$) or not
- [local] compute $\ell_E'$ using the previous comparison to 32 and potentially 2 byte decompositions of length 8 for either the high or low part of $\ell_E$ depending on whether the high part is nonzero or zero; also remember the leading byte and do its byte decomposition; we've done this sort of shit many times; derive $\ell_E'$ from that;
- [WCP] inquire whether $\ell_M < \ell_B$
  - from this we derive $m := \max \lbrace \ell_M , \ell_B \rbrace$
- [DIV] compute $q := \lceil m / 8 \rceil = \lfloor (m + 7) / 8 \rfloor$
- [DIV] compute $L := q^2 \cdot \max \lbrace \ell_E' , 1 \rbrace$ and compute $c := \lfloor L/ 3 \rfloor$
- [WCP] inquire whether $200 < c$
  - we thus have derived $g_r$
- [WCP] inquire whether $g_r > g_\text{stipend}$
  - this computs MODEXP_OOGX

![20231105_033041](https://github.com/Consensys/linea-besu-plugin/assets/38285177/b57c36fa-92b9-4ded-b83b-a9db822e4aa4)
![20231105_033049](https://github.com/Consensys/linea-besu-plugin/assets/38285177/0fbe0164-de64-4d82-8139-c532972039f7)


### Execution flow in the HUB

In terms of the HUB flow it goes as follows:
- SCENARIO predicts $\ell_B$, $\ell_E$, $\ell_M$
- launch a MMU instruction $\texttt{modexpSizeExtraction}$ using the following parameters:
  - CN
  - HUB_STAMP
  - CDS
  - CDO
- requires extracint 6 limbs (3 pairs of high and low parts) 
- lanch a MMU instruction $\texttt{modexpExtractExponentLeadingBytes}$ to get $\ell_E'$ (which requires the predicted data) 

Now comes the first bifucation: at this point we have enough information to detect MODEXP_OOGX
If it is raised then
- we provide the current execution context with empty return data

Otherwise we continue with the following:
- launch an MMU instruction $\texttt{extractModexpBase}$                           (iff $\ell_B \neq 0$, otherwise sit it out)
- launch an MMU instruction $\texttt{extractModexpExponent}$                       (iff $\ell_E \neq 0$, otherwise sit it out)
- launch an MMU instruction $\texttt{extractModexpModulus}$                        (iff $\ell_M \neq 0$, otherwise sit it out)
- launch an MMU instruction $\texttt{transferModexpResultToFictitiousContextsRam}$ (iff $\ell_M \neq 0$, otherwise sit it out)
- launch an MMU instruction $\texttt{copyRelevantPortionOfResultToCurrentRam}$     (iff $\ell_M \cdot \textsf{R@C} \neq 0$, otherwise sit it out)
- update current execution context's context dat with new updated return data      (returner = 1 + HUB_STAMP, RDO = 0, RAO)

### Simplification

I can simplify the transfer of data
- a nonzero RDO :D
- just copy the unadulterated data over, no byte decompositions required :D
- 32 limbs of 16 bytes

This will be far quicker and less painful than the messy copy :D

## MODEXP_DATA

### Representation

![20231104_033058](https://github.com/Consensys/linea-besu-plugin/assets/38285177/a93006f0-7f23-451d-9b73-9c0c07bd8039)
