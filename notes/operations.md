- [RAM instructions revisited](#ram-instructions-revisited)
  - [Classification](#classification)
    - [Instructions that touch RAM](#instructions-that-touch-ram)


# RAM instructions revisited

There will be a rewrite of the MMU module. This re-write will attempt the following things:
- homogenize instructions: several instructions are separate currently that shouldn't be since they do similar things in effect;
- in particular we can from the start use different instructions than the INST column of the HUB
- in particular all PRECOMPILE instructions will be treated the same way as the others (with CDL in CSD = 1 remaining a pain)
- furthermore, all the logic will be treated in RAM itself, e.g.:
    - extracting the EXO flags (see below)
    - dealing with CDL in the case where OFFSET >= CDS
    - dealing with RDCX (the return data copy exception)
- we will encode EXO sources using a single number, e.g. through an EXO_SOURCES column such that
    - EXO_SOURCES = \sum_i 2^bla EXO_IS_BLA[i] with exo sources such as
        - EXO_IS_ROM
        - EXO_IS_TXCD
        - EXO_IS_LOG
        - EXO_IS_KEC
        - EXO_IS_SHA2
        - EXO_IS_RIPEMD
        - EXO_IS_BLAKE2f
        - EXO_IS_MODEXP

Examples:
- for a successful RETURN in a deployment setting we can set (in the HUB) EXO_SOURCES = 2^rom[EXO_IS_ROM] + 2^kec[EXO_IS_KEC]
    - the KEC part allows us to retrieve the code hash
- for a successful CREATE2 we can set (in the HUB) EXO_SOURCES = 2^rom[EXO_IS_ROM] + 2^kec[EXO_IS_KEC]
    - the KEC part allows us to retrieve the initialization code hash

## Classification

### Instructions that touch RAM

| INST    | FLOW           | EXO       | modifier           | PARAMS                                               | STEPS      | pad |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| MLOAD   | RAM -> HUB     | ∅         | ∅                  | OFF1, CNS = CN, VAL                                  | XTRCT      | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| CDL     | EXO -> HUB     | TXCD      | CSD = 1            | OFF1, CDS, ABSTX#, VAL                               | WRITEZEROS | y   |
|         |                |           |                    |                                                      | GRABTHREE  | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| CDL     | RAM -> HUB     | ∅         | CSD > 1            | OFF1, CDS, ABSTX#, VAL                               | WRITEZEROS | y   |
|         |                |           |                    | several cases                                        | sev. cases | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| MSTORE  | HUB -> RAM     | ∅         | ∅                  | OFF1, CNT = CN, VAL                                  | INSERT     | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| MSTORE8 | HUB -> RAM     | ∅         | ∅                  | OFF1, CNT = CN, VAL                                  | INSERTBYTE | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| RETURN  | RAM -> RAM     | ∅         | CTYPE = 0, CSD = 1 | OFF1, SIZE, R@O, R@C, CNS = CN, CNT = CALLER, CSD    | ∅          | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| RETURN  | RAM -> RAM     | ∅         | CTYPE = 0, CSD > 1 | OFF1, SIZE, R@O, R@C, CNS = CN, CNT = CALLER, CSD    | COPY       | n   |
|         |                | ROM, SHA3 |                    |                                                      | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| REVERT  | RAM -> RAM     | ∅         | CTYPE = 0          | OFF1, SIZE, R@O, R@C, CNS = CN, CNT = CALLER         | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| CDC     | EXO -> RAM     | TXCD      | CSD = 1            | OFF1, SIZE, OFF2, CDO = 0, CDS, CNS = ∅, CNT = CN    | COPY       | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| CDC     | RAM -> RAM     | ∅         | CSD > 1            | OFF1, SIZE, OFF2, CDO, CDS, CNS = CALLER, CNT = CN   | COPY       | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| RDC     | RAM ->         | ∅         |                    | OFF1, SIZE, OFF2, RDO, RDS, CNS = RETURNER, CNT = CN | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| CC      | ROM -> RAM     | ROM       |                    | OFF1, SIZE, OFF2, CODESIZE, CNT = CN, ADDR           | COPY       | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| EXTCC   | ROM -> ROM     | ROM       | depStatus = 0      | OFF1, SIZE, OFF2, CODESIZE, CNT = CN, ADDR           | WRITEZEROS | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| EXTCC   | ROM -> ROM     | ROM       | depStatus = 1      | OFF1, SIZE, OFF2, CODESIZE, CNT = CN, ADDR           | COPY       | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| SHA3    | RAM -> SHA3    | SHA3_DATA |                    | OFF1, SIZE, CNS = CN, HUBSTAMP                       | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| LOGX    | RAM -> LOG     | LOG_DATA  |                    | OFF1, SIZE, CNS = CN, LOGSTAMP                       | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x01    | RAM -> ECD     | EC_DATA   | TOUCHES_RAM = 1    | CDO, CDS, REFS = 128, CNS = CN, HUBSTAMP             | COPY       | y   |
|         | ECI -> RAM     | EC_DATA   | PROVIDES_RD = 1    | RDS = 32, CNT = 1 + HUBSTAMP                         | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, REFS = 32, CNS = 1 + HUBSTAMP, CNT = CN    | COPY       | y   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x02    | RAM -> SHA2    | SHA2      | TOUCHES_RAM = 1    | CDO, CDS, REFS = 128, CNS = CN, HUBSTAMP             | COPY       | y   |
|         | ECI -> RAM     | SHA2      | TOUCHES_RAM = 1    | RDS = 32, CNT = 1 + HUBSTAMP                         | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, REFS = 32, CNS = 1 + HUBSTAMP, CNT = CN    | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x03    | RAM -> RIPEMD  | RIPEMD    | TOUCHES_RAM = 1    | CDO, CDS, REFS = 128, CNS = CN, HUBSTAMP             | COPY       | y   |
|         | ECI -> RAM     | RIPEMD    | TOUCHES_RAM = 1    | RDS = 32, CNT = 1 + HUBSTAMP                         | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, RDS = 32, CNS = 1 + HUBSTAMP, CNT = CN     | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x04    | RAM -> RAM     | ∅         | TOUCHES_RAM = 1    | CDO, CDS, CNS = CN, CNT = 1 + HUBSTAMP               | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, RDS = CDS, CNS = 1 + HUBSTAMP, CNT = CN    | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x05    | RAM -> MODEXP  | MODEXP    | TOUCHES_RAM = 1    | CDO, CDS, CNS = CN, HUBSTAMP                         | COPY       | y   |
|         | MODEXP -> RAM  | MODEXP    | PROVIDES_RD = 1    | RDS = l_M, CNT = 1 + HUBSTAMP, HUBSTAMP              | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, RDS, CNS = 1 + HUBSTAMP, CNT = CN          | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x06    | RAM -> ECD     | EC_DATA   | TOUCHES_RAM = 1    | CDO, CDS, CNS = CN, HUBSTAMP                         | COPY       | y   |
|         | ECD -> RAM     | EC_DATA   | PROVIDES_RD = 1    | RDS = l_M, CNT = 1 + HUBSTAMP, HUBSTAMP              | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, RDS, CNS = 1 + HUBSTAMP, CNT = CN          | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x07    | RAM -> ECD     | EC_DATA   | TOUCHES_RAM = 1    | CDO, CDS, CNS = CN, HUBSTAMP                         | COPY       | y   |
|         | ECD -> RAM     | EC_DATA   | PROVIDES_RD = 1    | RDS = l_M, CNT = 1 + HUBSTAMP, HUBSTAMP              | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, RDS, CNS = 1 + HUBSTAMP, CNT = CN          | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x08    | RAM -> ECD     | EC_DATA   | TOUCHES_RAM = 1    | CDO, CDS, CNS = CN, HUBSTAMP                         | COPY       | y   |
|         | ECD -> RAM     | EC_DATA   | PROVIDES_RD = 1    | RDS = l_M, CNT = 1 + HUBSTAMP, HUBSTAMP              | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, RDS, CNS = 1 + HUBSTAMP, CNT = CN          | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
| 0x09    | RAM -> BLAKE2f | BLAKE2f   | TOUCHES_RAM = 1    | CDO, CDS, CNS = CN, HUBSTAMP                         | COPY       | y   |
|         | BLAKE2f -> RAM | BLAKE2f   | PROVIDES_RD = 1    | RDS = l_M, CNT = 1 + HUBSTAMP, HUBSTAMP              | COPY       | n   |
|         | RAM -> RAM     | ∅         | and R@C != 0       | R@O, R@C, RDS, CNS = 1 + HUBSTAMP, CNT = CN          | COPY       | n   |
|---------|----------------|-----------|--------------------|------------------------------------------------------|------------|-----|
