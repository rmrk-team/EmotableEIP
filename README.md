---
eip: x
title: Emotable Non-Fungible Tokens
description: x
author: Bruno Škvorc (@Swader), Cicada (@CicadaNCR), Steven Pineda (@steven2308), Stevan Bogosavljevic (@stevyhacker), Jan Turk (@ThunderDeliverer)
discussions-to: x
status: Draft
type: Standards Track
category: ERC
created: 2023-01-22
requires: 165, 721
---

## Abstract



## Motivation



## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

```solidity
/// @title EIP-x Emotable Non-Fungible Tokens
/// @dev See https://eips.ethereum.org/EIPS/eip-5773
/// @dev Note: the ERC-165 identifier for this interface is 0x0.

pragma solidity ^0.8.16;


```

## Rationale



## Backwards Compatibility



## Test Cases

Tests are included in [`emotable.ts`](../assets/eip-x/test/emotable.ts).

To run them in terminal, you can use the following commands:

```
cd ../assets/eip-x
npm install
npx hardhat test
```

## Reference Implementation

See [`Emotable.sol`](../assets/eip-x/contracts/Emotable.sol).

## Security Considerations

The same security considerations as with [EIP-721](./eip-721.md) apply: hidden logic may be present in any of the functions, including burn, add asset, accept asset, and more.

Caution is advised when dealing with non-audited contracts.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
