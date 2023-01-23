---
eip: x
title: Emotable Extension for Non-Fungible Tokens
description: An interface for Non-Fungible Tokens extension allowing for reacting to them using Unicode emojis.
author: Bruno Škvorc (@Swader), Cicada (@CicadaNCR), Steven Pineda (@steven2308), Stevan Bogosavljevic (@stevyhacker), Jan Turk (@ThunderDeliverer)
discussions-to: x
status: Draft
type: Standards Track
category: ERC
created: 2023-01-22
requires: 165, 721
---

## Abstract

The Emotable Extension for Non-Fungible Tokens standard extends [EIP-721](./eip-721.md) by allowing NFTs to be emoted at.

This proposal introduces the ability to react to NFTs using Unicode standardized emoji.

## Motivation

With NFTs being a widespread form of tokens in the Ethereum ecosystem and being used for a variety of use cases, it is time to standardize additional utility for them. Having the ability for anyone to interact with an NFT introduces an interactive aspect to owning an NFT and unlocks feedback-based NFT mechanics.

This EIP introduces new utilities for [EIP-721](./eip-721.md) based tokens in the following areas:

- [Interactivity](#interactivity)
- [Feedback based evolution](#feedback-based-evolution)

### Interactivity

The ability to emote on an NFT introduces the aspect of interactivity to owning an NFT. This can either reflect the admiration for the emoter (person emoting to an NFT) or can be a result of a certain action performed by the token's owner. Accumulating emotes on a token can increase its uniqueness and/or value.

### Feedback based evolution

Standardized on-chain reactions to NFTs allow for feedback based evolution.

Current solutions are either proprietary or off-chain and therefore subject to manipulation and distrust. Having the ability to track the interaction on-chain allows for trust and objective evaluation of a given token. Designing the tokens to evolve when certain emote thresholds are met incentivizes interaction with the token collection.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

```solidity
/// @title EIP-x Emotable Extension for Non-Fungible Tokens
/// @dev See https://eips.ethereum.org/EIPS/eip-5773
/// @dev Note: the ERC-165 identifier for this interface is 0x0.

pragma solidity ^0.8.16;

interface IRMRKEmotable is IERC165 {
    /**
     * @notice Used to get the number of emotes for a specific emoji on a token.
     * @param tokenId ID of the token to check for emoji count
     * @param emoji Unicode identifier of the emoji
     * @return Number of emotes with the emoji on the token
     */
    function getEmoteCount(
        uint256 tokenId,
        bytes4 emoji
    ) external view returns (uint256);

    /**
     * @notice Used to emote or undo an emote on a token.
     * @dev Does nothing if attempting to set a pre-existent state
     * @param tokenId ID of the token being emoted
     * @param emoji Unicode identifier of the emoji
     * @param state Boolean value signifying whether to emote (`true`) or undo (`false`) emote
     */
    function emote(uint256 tokenId, bytes4 emoji, bool state) external;
}
```

## Rationale



## Backwards Compatibility

The Emotable token standard is fully compatible with [EIP-721](./epi-721.md) and with the robust tooling available for implementations of EIP-721 as well as with the existing EIP-721 infrastructure.

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
