// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.16;

import "./IERC6381.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

error BulkParametersOfUnequalLength();
error ExpiredPresignedEmote();
error InvalidSignature();

contract EmotableRepository is IERC6381 {
    bytes32 public constant DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            "ERC-6381: Public Non-Fungible Token Emote Repository",
            "1",
            block.chainid,
            address(this)
        )
    );
    bytes32 public constant EMOTE_TYPEHASH = keccak256(
        "emote(address collection,uint256 tokenId,bytes4 emoji,bool state)"
    );

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

    function bulkEmoteCountOf(
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis
    ) public view returns (uint256[] memory) {
        if(
            collections.length != tokenIds.length ||
                collections.length != emojis.length
        ){
            revert BulkParametersOfUnequalLength();
        }

        uint256[] memory counts = new uint256[](collections.length);
        for (uint256 i; i < collections.length; ) {
            counts[i] = _emotesPerToken[collections[i]][tokenIds[i]][emojis[i]];
            unchecked {
                ++i;
            }
        }
        return counts;
    }

    function hasEmoterUsedEmote(
        address emoter,
        address collection,
        uint256 tokenId,
        bytes4 emoji
    ) public view returns (bool) {
        return _emotesUsedByEmoter[emoter][collection][tokenId][emoji] == 1;
    }

    function haveEmotersUsedEmotes(
        address[] memory emoters,
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis
    ) public view returns (bool[] memory) {
        if(
            emoters.length != collections.length ||
                emoters.length != tokenIds.length ||
                emoters.length != emojis.length
        ){
            revert BulkParametersOfUnequalLength();
        }

        bool[] memory states = new bool[](collections.length);
        for (uint256 i; i < collections.length; ) {
            states[i] = _emotesUsedByEmoter[emoters[i]][collections[i]][tokenIds[i]][emojis[i]] == 1;
            unchecked {
                ++i;
            }
        }
        return states;
    }

    function emote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state
    ) public {
        bool currentVal = _emotesUsedByEmoter[msg.sender][collection][tokenId][
            emoji
        ] == 1;
        if (currentVal != state) {
            if (state) {
                _emotesPerToken[collection][tokenId][emoji] += 1;
            } else {
                _emotesPerToken[collection][tokenId][emoji] -= 1;
            }
            _emotesUsedByEmoter[msg.sender][collection][tokenId][emoji] = state
                ? 1
                : 0;
            emit Emoted(msg.sender, collection, tokenId, emoji, state);
        }
    }

    function bulkEmote(
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis,
        bool[] memory states
    ) public {
        if(
            collections.length != tokenIds.length ||
                collections.length != emojis.length ||
                collections.length != states.length
        ){
            revert BulkParametersOfUnequalLength();
        }

        bool currentVal;
        for (uint256 i; i < emoters.length; ) {
            currentVal = _emotesUsedByEmoter[msg.sender][collections[i]][tokenIds[i]][
                emojis[i]
            ] == 1;
            if (currentVal != states[i]) {
                if (states[i]) {
                    _emotesPerToken[collections[i]][tokenIds[i]][emojis[i]] += 1;
                } else {
                    _emotesPerToken[collections[i]][tokenIds[i]][emojis[i]] -= 1;
                }
                _emotesUsedByEmoter[msg.sender][collections[i]][tokenIds[i]][emojis[i]] = states[i]
                    ? 1
                    : 0;
                emit Emoted(msg.sender, collections[i], tokenIds[i], emojis[i], states[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    function presignedEmote(
        address collection,
        uint256 tokenId,
        bytes4 emoji,
        bool state,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        if(block.timestamp > deadline){
            revert ExpiredPresignedEmote();
        }
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        EMOTE_TYPEHASH,
                        collection,
                        tokenId,
                        emoji,
                        state,
                        deadline
                    )
                )
            )
        );
        address signer = ecrecover(digest, v, r, s);
        if(signer == address(0)){
            revert InvalidSignature();
        }
        
        bool currentVal = _emotesUsedByEmoter[signer][collection][tokenId][
            emoji
        ] == 1;
        if (currentVal != state) {
            if (state) {
                _emotesPerToken[collection][tokenId][emoji] += 1;
            } else {
                _emotesPerToken[collection][tokenId][emoji] -= 1;
            }
            _emotesUsedByEmoter[signer][collection][tokenId][emoji] = state
                ? 1
                : 0;
            emit Emoted(signer, collection, tokenId, emoji, state);
        }
    }
    
    function bulkPresignedEmote(
        address[] memory collections,
        uint256[] memory tokenIds,
        bytes4[] memory emojis,
        bool[] memory states,
        uint256[] memory deadlines,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) public {
        if(
            collections.length != tokenIds.length ||
                collections.length != emojis.length ||
                collections.length != states.length ||
                collections.length != deadlines.length ||
                collections.length != v.length ||
                collections.length != r.length ||
                collections.length != s.length
        ){
            revert BulkParametersOfUnequalLength();
        }

        bytes32 digest;
        address signer;
        bool currentVal;
        for (uint256 i; i < emoters.length; ) {
            if (block.timestamp > deadlines[i]){
                revert ExpiredPresignedEmote();
            }
            digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            EMOTE_TYPEHASH,
                            collections[i],
                            tokenIds[i],
                            emojis[i],
                            states[i],
                            deadlines[i]
                        )
                    )
                )
            );
            signer = ecrecover(digest, v[i], r[i], s[i]);
            if(signer == address(0)){
                revert InvalidSignature();
            }
            
            currentVal = _emotesUsedByEmoter[signer][collections[i]][tokenIds[i]][
                emojis[i]
            ] == 1;
            if (currentVal != states[i]) {
                if (states[i]) {
                    _emotesPerToken[collections[i]][tokenIds[i]][emojis[i]] += 1;
                } else {
                    _emotesPerToken[collections[i]][tokenIds[i]][emojis[i]] -= 1;
                }
                _emotesUsedByEmoter[signer][collections[i]][tokenIds[i]][emojis[i]] = states[i]
                    ? 1
                    : 0;
                emit Emoted(signer, collections[i], tokenIds[i], emojis[i], states[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return
            interfaceId == type(IERC6381).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}