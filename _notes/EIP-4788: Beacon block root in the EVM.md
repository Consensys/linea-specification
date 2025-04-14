# Tasks

## HUB

In order to accomodate this EIP and other system level transactions (e.g. [EIP-2935: Save historical block hashes in state](https://eips.ethereum.org/EIPS/eip-2935)) we will implement an upgradable solution. As it stands today all system level transactions that are being considered are of the form
- upgrade the storage of some smart contract prior to transaction processing

The upgrade path is that we will want
