# Notes from today

## Description of the problem

The Arithmetization (specifially the HUB) and Shomei don't require/produce the same state data. This has, and will continue to, cause trouble when connecting the HUB to the State Manager.

In general we should aim to have it so that every Shomei insight is reflected in the HUB. For the converse it's going to be difficult. There are cases where the HUB requires more insights into the state than Shomei provides (since it can skip them.) The fundamental reason for this is that the HUB includes **accrued state data** (account/storage warmths mostly, but also accounts being marked for selfdestruct) at the same level as **EVM state data** in the relevant account/storage perspective. When only the accrued state data is necessary e.g. to price an opcode (whose pricing depends on the warmth of something and which will raise an OOGX), the HUB will need the **full** account/storage data even in the case where the opcode raises an OOGX; Shomei typically won't transcribe that data as it's not required.

The Arithmetization has plenty of tests which will trigger such scenarios of information discrepancies. The question is then how to leverage those tests in conjunction with Shomei, and the State Manager.

## Testing

Here are the options we discussed:
- **Option 1:** rewriting/reformatting the relevant tests in a way that can easily be passed on to other components;
- **Option 2:** extracting from the tests the required data; @Karim.Taam suggested to provide a two object json per test with
    - a genesis file configuration (in case we pre-populate the state with accounts, which we typically do)
    - a list of transactions (which we also construct for our unit tests)
    - the idea would then be that
        - the Arithmetization extracts this json (and maybe produces the associated `.lt` files)
        - the json gets processed by a Besu-Shomei node thus producing the Shomei trace
        - the `.lt` and `.shomei` files are consumed by the State Manager / Prover in an integration test


@Karim.Taam mentioned that in order to produce the genesis config we take inspiration from the genesis files we have for Linea. Depending on whether our tests use Bonzai or not we could use the `streamFlatAccount` or `streamFlatStorage` methods (not sure about the names) or alternatively if we use an in memory database (imdb) we could produce the Genesis file from the imdb.

## Shomei changes

We also discussed the possibility for Shomei to include account data / storage values for accounts / storage keys that get pre-warmed in access-list transactions. The rationale is that
- pre-warming costs money (~90% of the cost it would be to touch an account / storage key during execution)
    - this means that including the relevant data in the Shomei transcript cannot be used in a DOS attack (as you are essentially paying full price for these operations)
- @Karim.Taam and @Ameziane.Hamlat already discussed this but didn't implement this since low priority (access list transactions are rare)
- one would have to be careful about performance and how and where to implement this feature

## Next steps

- we will discuss the "access-lists in Shomei" stuff next week
- we could ask @Julien.Marchand if someone on his team could assist with either task (testing and/or Shomei changes)

The first option may be the fastest: we need to identify the relevant tests and work out how to package them. It's going to get complex if these tests require us to prepare the state in some way. Also we will be having the same issue with future upgrades of the EVM and/or big changes à la becoming a Type 1 zkevm. Also we may miss crucial tests that trigger interesting behaviour but without that being the proclaimed purpose of the test. It's not future proof but may help us deploy faster.

The second option may be time consuming and may delay mainnet launch.

There is the third option of doing both, the first one in the short term, the second one for the long term.
