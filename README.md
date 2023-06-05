---
eip: 6381
title: Public Non-Fungible Token Emote Repository
description: React to any Non-Fungible Tokens using Unicode emojis.
author: Bruno Škvorc (@Swader), Steven Pineda (@steven2308), Stevan Bogosavljevic (@stevyhacker), Jan Turk (@ThunderDeliverer)
discussions-to: https://ethereum-magicians.org/t/eip-6381-emotable-extension-for-non-fungible-tokens/12710
status: Review
type: Standards Track
category: ERC
created: 2023-01-22
requires: 165
---

## Abstract

The Public Non-Fungible Token Emote Repository standard provides an enhanced interactive utility for [ERC-721](./eip-721.md) and [ERC-1155](./eip-1155.md) by allowing NFTs to be emoted at.

This proposal introduces the ability to react to NFTs using Unicode standardized emoji in a public non-gated repository smart contract that is accessible at the same address in all of the networks.

## Motivation

With NFTs being a widespread form of tokens in the Ethereum ecosystem and being used for a variety of use cases, it is time to standardize additional utility for them. Having the ability for anyone to interact with an NFT introduces an interactive aspect to owning an NFT and unlocks feedback-based NFT mechanics.

This ERC introduces new utilities for [ERC-721](./eip-721.md) based tokens in the following areas:

- [Interactivity](#interactivity)
- [Feedback based evolution](#feedback-based-evolution)
- [Valuation](#valuation)

### Interactivity

The ability to emote on an NFT introduces the aspect of interactivity to owning an NFT. This can either reflect the admiration for the emoter (person emoting to an NFT) or can be a result of a certain action performed by the token's owner. Accumulating emotes on a token can increase its uniqueness and/or value.

### Feedback based evolution

Standardized on-chain reactions to NFTs allow for feedback based evolution.

Current solutions are either proprietary or off-chain and therefore subject to manipulation and distrust. Having the ability to track the interaction on-chain allows for trust and objective evaluation of a given token. Designing the tokens to evolve when certain emote thresholds are met incentivizes interaction with the token collection.

### Valuation

Current NFT market heavily relies on previous values the token has been sold for, the lowest price of the listed token and the scarcity data provided by the marketplace. There is no real time indication of admiration or desirability of a specific token. Having the ability for users to emote to the tokens adds the possibility of potential buyers and sellers gauging the value of the token based on the impressions the token has collected.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

```solidity
/// @title ERC-6381 Emotable Extension for Non-Fungible Tokens
/// @dev See https://eips.ethereum.org/EIPS/eip-6381
/// @dev Note: the ERC-165 identifier for this interface is 0x761ce19f.

pragma solidity ^0.8.16;

interface IERC6381 /*is IERC165*/ {
    /**
     * @notice Used to notify listeners that the token with the specified ID has been emoted to or that the reaction has been revoked.
     * @dev The event MUST only be emitted if the state of the emote is changed.
     * @param emoter Address of the account that emoted or revoked the reaction to the token
     * @param collection Address of the collection smart contract containing the token being emoted to or having the reaction revoked
     * @param tokenId ID of the token
     * @param emoji Unicode identifier of the emoji
     * @param on Boolean value signifying whether the token was emoted to (`true`) or if the reaction has been revoked (`false`)
     */
    event Emoted(
        address indexed emoter,
        address indexed collection,
        uint256 indexed tokenId,
        bytes4 emoji,
        bool on
    );

    /**
     * @notice Used to get the number of emotes for a specific emoji on a token.
     * @param collection Address of the collection containing the token being checked for emoji count
     * @param tokenId ID of the token to check for emoji count
     * @param emoji Unicode identifier of the emoji
     * @return Number of emotes with the emoji on the token
     */
    function emoteCountOf(
        address collection,
        uint256 tokenId,
        bytes4 emoji
    ) external view returns (uint256);

    /**
     * @notice Used to get the number of emotes for a specific emoji on a set of tokens.
     * @param collection An array of addresses of the collections containing the tokens being checked for emoji count
     * @param tokenIds An array of IDs of the tokens to check for emoji count
     * @param emojis An array of unicode identifiers of the emojis
     * @return An array of numbers of emotes with the emoji on the tokens
     */
    function bulkEmoteCountOf(
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis
    ) external view returns (uint256[] memory);

    /**
     * @notice Used to get the information on whether the specified address has used a specific emoji on a specific
     *  token.
     * @param emoter Address of the account we are checking for a reaction to a token
     * @param collection Address of the collection smart contract containing the token being checked for emoji reaction
     * @param tokenId ID of the token being checked for emoji reaction
     * @param emoji The ASCII emoji code being checked for reaction
     * @return A boolean value indicating whether the `emoter` has used the `emoji` on the token (`true`) or not
     *  (`false`)
     */
    function hasEmoterUsedEmote(
        address emoter,
        address collection,
        uint256 tokenId,
        bytes4 emoji
    ) external view returns (bool);

    /**
     * @notice Used to get the information on whether the specified addresses have used specific emojis on specific
     *  tokens.
     * @param collections An array of addresses of the collection smart contracts containing the tokens being checked
     *  for emoji reactions
     * @param emoters An array of addresses of the accounts we are checking for reactions to tokens
     * @param tokenIds An array of IDs of the tokens being checked for emoji reactions
     * @param emojis An array of the ASCII emoji codes being checked for reactions
     * @return An array of boolean values indicating whether the `emoter`s has used the `emoji`s on the tokens (`true`)
     *  or not (`false`)
     */
    function haveEmotersUsedEmotes(
        address[] memory emoters,
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis
    ) external view returns (bool[] memory);

    /**
     * @notice Used to get the message to be signed by the `emoter` in order for the reaction to be submitted by someone
     *  else.
     * @param collection The addresses of the collection smart contract containing the token being emoted at
     * @param tokenId ID of the token being emoted
     * @param emoji Unicode identifier of the emoji
     * @param state Boolean value signifying whether to emote (`true`) or undo (`false`) emote
     * @param deadline UNIX timestamp of the deadline for the signature to be submitted
     * @return The message to be signed by the `emoter` in order for the reaction to be submitted by someone else
     */
    function prepareMessageToPresignEmote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state,
        uint256 deadline
    ) external view returns (bytes32);

    /**
     * @notice Used to emote or undo an emote on a token.
     * @dev Does nothing if attempting to set a pre-existent state.
     * @dev MUST emit the `Emoted` event is the state of the emote is changed.
     * @param collection Address of the collection containing the token being emoted at
     * @param tokenId ID of the token being emoted
     * @param emoji Unicode identifier of the emoji
     * @param state Boolean value signifying whether to emote (`true`) or undo (`false`) emote
     */
    function emote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state
    ) external;

    /**
     * @notice Used to emote or undo an emote on multiple tokens.
     * @dev Does nothing if attempting to set a pre-existent state.
     * @dev MUST emit the `Emoted` event is the state of the emote is changed.
     * @dev MUST revert if the lengths of the `collections`, `tokenIds`, `emojis` and `states` arrays are not equal.
     * @param collections An array of addresses of the collections containing the tokens being emoted at
     * @param tokenIds An array of IDs of the tokens being emoted
     * @param emojis An array of unicode identifiers of the emojis
     * @param states An array of boolean values signifying whether to emote (`true`) or undo (`false`) emote
     */
    function bulkEmote(
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis,
        bool[] memory states
    ) external;

    /**
     * @notice Used to emote or undo an emote on someone else's behalf.
     * @dev Does nothing if attempting to set a pre-existent state.
     * @dev MUST emit the `Emoted` event is the state of the emote is changed.
     * @dev MUST revert if the lengths of the `collections`, `tokenIds`, `emojis` and `states` arrays are not equal.
     * @dev MUST revert if the `deadline` has passed.
     * @dev MUST revert if the recovered address is the zero address.
     * @param collection Addresses of the collections containing the token being emoted at
     * @param tokenId IDs of the token being emoted
     * @param emoji Unicode identifier of the emoji
     * @param states Boolean value signifying whether to emote (`true`) or undo (`false`) emote
     * @param deadline UNIX timestamp of the deadline for the signature to be submitted
     * @param v `v` value of an ECDSA signature of the message obtained via `prepareMessageToPresignEmote`
     * @param r `r` value of an ECDSA signature of the message obtained via `prepareMessageToPresignEmote`
     * @param s `s` value of an ECDSA signature of the message obtained via `prepareMessageToPresignEmote`
     */
    function presignedEmote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @notice Used to bulk emote or undo an emote on someone else's behalf.
     * @dev Does nothing if attempting to set a pre-existent state.
     * @dev MUST emit the `Emoted` event is the state of the emote is changed.
     * @dev MUST revert if the lengths of the `collections`, `tokenIds`, `emojis` and `states` arrays are not equal.
     * @dev MUST revert if the `deadline` has passed.
     * @dev MUST revert if the recovered address is the zero address.
     * @param collections An array of addresses of the collections containing the tokens being emoted at
     * @param tokenIds An array of IDs of the tokens being emoted
     * @param emojis An array of unicode identifiers of the emojis
     * @param states An array of boolean values signifying whether to emote (`true`) or undo (`false`) emote
     * @param deadline UNIX timestamp of the deadline for the signature to be submitted
     * @param v An array of `v` values of an ECDSA signatures of the messages obtained via `prepareMessageToPresignEmote`
     * @param r An array of `r` values of an ECDSA signatures of the messages obtained via `prepareMessageToPresignEmote`
     * @param s An array of `s` values of an ECDSA signatures of the messages obtained via `prepareMessageToPresignEmote`
     */
    function bulkPresignedEmote(
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis,
        bool[] memory states,
        uint256[] memory deadlines,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;
}
```

### Pre-determined address of the Emotable repository

The address of the Emotable repository smart contract is designed to resemble the function it serves. It starts with `0x311073` which is the abstract representation of `EMOTE`. The address is:

```
TBA
```

## Rationale

Designing the proposal, we considered the following questions:

1. **Does the proposal support custom emotes or only the Unicode specified ones?**\
The proposal only accepts the Unicode identifier which is a `bytes4` value. This means that while we encourage implementers to add the reactions using standardized emojis, the values not covered by the Unicode standard can be used for custom emotes. The only drawback being that the interface displaying the reactions will have to know what kind of image to render and such additions will probably be limited to the interface or marketplace in which they were made.
2. **Should the proposal use emojis to relay the impressions of NFTs or some other method?**\
The impressions could have been done using user-supplied strings or numeric values, yet we decided to use emojis since they are a well established mean of relaying impressions and emotions.
3. **Should the proposal establish an emotable extension or a common-good repository?**\
Initially we set out to create an emotable extension to be used with any ERC-721 compilant tokens. However, we realized that the proposal would be more useful if it was a common-good repository of emotable tokens. This way, the tokens that can be reacted to are not only the new ones but also the old ones that have been around since before the proposal.\
In line with this decision, we decided to calculate a deterministic address for the repository smart contract. This way, the repository can be used by any NFT collection without the need to search for the address on the given chain.

## Backwards Compatibility

The Emote repository standard is fully compatible with [ERC-721](./eip-721.md) and with the robust tooling available for implementations of ERC-721 as well as with the existing ERC-721 infrastructure.

## Test Cases

Tests are included in [`emoteRepository.ts`](../assets/eip-6381/test/emoteRepository.ts).

To run them in terminal, you can use the following commands:

```
cd ../assets/eip-6381
npm install
npx hardhat test
```

## Reference Implementation

See [`EmoteRepository.sol`](../assets/eip-6381/contracts/EmoteRepository.sol).

## Security Considerations

The same security considerations as with [ERC-721](./eip-721.md) apply: hidden logic may be present in any of the functions, including burn, add asset, accept asset, and more.

Caution is advised when dealing with non-audited contracts.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
