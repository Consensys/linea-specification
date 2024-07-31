# LOG_RLP, LOG_DATA, LOG_INFO

## Main issue

We currently have 3 modules dealing with LOGs: LOG_INFO, LOG_DATA, LOG_RLP. The LOG_RLP module is a consumer of the data logged in the other two modules and associated lookup arguments are required.

## Relevant data from LOG_DATA and LOG_INFO

- LOG_INFO
	- LOG_NUMBER
	- ADDR_HI / ADDR_LO
	- SIZE
	- INST (i.e. LOG0 - LOG4)
	- TOPIC_1_HI / TOPIC_1_LO,
	- TOPIC_2_HI / TOPIC_2_LO,
	- TOPIC_3_HI / TOPIC_3_LO,
	- TOPIC_4_HI / TOPIC_4_LO,
- LOG_DATA
	- LOG_NUMBER
	- LIMB: already known to be 16 byte integers, left aligned on the 16 byte
    - nBYTES
    - INDEX

## Verticalization for LOG_INFO

**Note.** As with the TX_DATA module it will likely make sense to duplicate the data in LOG_INFO to make it "vertically available" in the LOG_RLP module. We can do _verticalization_ as follows: we will require a VAL_HI / VAL_LO column that will present as follows:

| VAL_HI     | VAL_LO     | LOG_NUMBER | INST | ... |
|------------|------------|------------|------|-----|
| ...        | ...        | ...        | ...  | ... |
|------------|------------|------------|------|-----|
| addr_hi    | addr_lo    | 16         | LOG0 | ... |
| 0          | dataSize   | 16         | LOG0 | ... |
|------------|------------|------------|------|-----|
| addr_hi    | addr_lo    | 17         | LOG3 | ... |
| topic_1_hi | topic_1_lo | 17         | LOG3 | ... |
| topic_2_hi | topic_2_lo | 17         | LOG3 | ... |
| topic_3_hi | topic_3_lo | 17         | LOG3 | ... |
| 0          | dataSize   | 17         | LOG3 | ... |
|------------|------------|------------|------|-----|
| addr_hi    | addr_lo    | 18         | LOG1 | ... |
| topic_1_hi | topic_1_lo | 18         | LOG1 | ... |
| 0          | dataSize   | 18         | LOG1 | ... |
|------------|------------|------------|------|-----|
| addr_hi    | addr_lo    | 19         | LOG4 | ... |
| topic_1_hi | topic_1_lo | 19         | LOG4 | ... |
| topic_2_hi | topic_2_lo | 19         | LOG4 | ... |
| topic_3_hi | topic_3_lo | 19         | LOG4 | ... |
| topic_4_hi | topic_4_lo | 19         | LOG4 | ... |
| 0          | dataSize   | 19         | LOG4 | ... |
|------------|------------|------------|------|-----|
| ...        | ...        | ...        | ...  | ... |

## Unjustified data

The TX_RLP module encode currently unjustified data: $R_x, R_z, R_u, R_b$. Here's a the road map to get these values fully justified:
- $R_x$ is available in TX_DATA (indexed by ABS_TX_NUM)
- $R_z$ can be made available in TX_DATA (indexed by ABS_TX_NUM)
- $R_u$ can be made available in TX_DATA (indexed by ABS_TX_NUM)
- $R_b$ there are currently no plans to justify it ...
