// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.16;

import "./IEmotableRepository.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract EmotableRepository is IEmotableRepository {
    // Used to avoid double emoting and control undoing
    mapping(address => mapping(address => mapping(uint256 => mapping(bytes4 => uint256))))
        private _emotesUsedByEmoter; // Cheaper than using a bool
    mapping(address => mapping(uint256 => mapping(bytes4 => uint256)))
        private _emotesPerToken;

    function emoteCountOf(
        address collection,
        uint256 tokenId,
        bytes4 emoji
    ) public view returns (uint256) {
        return _emotesPerToken[collection][tokenId][emoji];
    }

    function hasEmoterUsedEmote(
        address emoter,
        address collection,
        uint256 tokenId,
        bytes4 emoji
    ) public view returns (bool) {
        return _emotesUsedByEmoter[emoter][collection][tokenId][emoji] == 1;
    }

     function emote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state
    ) external override {
        _emote(collection, tokenId, emoji, state);
    }

    function _emote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state
    ) internal virtual {
        bool currentVal = _emotesUsedByEmoter[msg.sender][collection][tokenId][
            emoji
        ] == 1;
        if (currentVal != state) {
            _beforeEmote(collection, tokenId, emoji, state);
            if (state) {
                _emotesPerToken[collection][tokenId][emoji] += 1;
            } else {
                _emotesPerToken[collection][tokenId][emoji] -= 1;
            }
            _emotesUsedByEmoter[msg.sender][collection][tokenId][emoji] = state
                ? 1
                : 0;
            emit Emoted(msg.sender, collection, tokenId, emoji, state);
            _afterEmote(collection, tokenId, emoji, state);
        }
    }

    function _beforeEmote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state
    ) internal virtual {}

    function _afterEmote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state
    ) internal virtual {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return
            interfaceId == type(IEmotableRepository).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}