//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    //also use SafeIERC overriden functions for IERC20 interface
    using SafeERC20 for IERC20;

    //Errors
    error MerkleAirdrop__NotInMerkleProof();
    error MerkleAirdrop__UserAlreadyReedemed();

    //Events
    event Claim(address account, uint256 amountToClaim);

    mapping(address claimer => bool claimed) private s_alreadyClaimed;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amountToClaim, bytes32[] calldata merkleProof) external {
        if (s_alreadyClaimed[account]) {
            revert MerkleAirdrop__UserAlreadyReedemed();
        }
        //calculate the hash using the account and amount
        //hashing it twice is required to prevent second-reimage attacks, aka make it computationally infeasible to find another input which produces the same output
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amountToClaim))));
        //Openzep has contract for merkleproofs
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__NotInMerkleProof();
        }
        emit Claim(account, amountToClaim);
        i_airdropToken.transfer(account, amountToClaim);
        s_alreadyClaimed[account] = true;
    }

    function getMerkelRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
