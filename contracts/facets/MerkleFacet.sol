// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";

contract MerkleFacet {
    bytes32 public merkleRoot;

    function setMerkleRoot(bytes32 _merkleRoot) external {
        // Ensure only contract owner can set the Merkle root
        LibDiamond.enforceIsContractOwner();
        merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata proof) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(verify(proof, leaf), "Invalid proof");
        
        // Implement logic to mint an NFT to the claimer
        ERC721Facet(address(this)).mint(msg.sender);
    }

    /**
     * @dev Verifies a Merkle proof
     * @param proof An array of 32-byte values representing the Merkle proof
     * @param leaf A 32-byte value representing the leaf of the Merkle tree
     * @return True if the proof is valid, false otherwise
     */
    function verify(bytes32[] memory proof, bytes32 leaf) internal view returns (bool) {
        // Start with the leaf node
        bytes32 computedHash = leaf;

        // Iterate over the proof
        for (uint256 i = 0; i < proof.length; i++) {
            // Compute the hash of the current node and the next node in the proof
            computedHash = computedHash < proof[i] ? 
                keccak256(abi.encodePacked(computedHash, proof[i])) : 
                keccak256(abi.encodePacked(proof[i], computedHash));
        }

        // Check if the computed hash matches the root of the Merkle tree
        return computedHash == merkleRoot;
    }
}
