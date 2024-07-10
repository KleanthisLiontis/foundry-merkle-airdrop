//SPDX-License-Identifier:MIT

pragma solidity ^0.8.26;

import {MerkleAirdrop, IERC20} from "../src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {console} from "forge-std/console.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    // 4 users, 25 tokens each
    uint256 private AMOUNT_AIRDROPPED_PER_ADDRESS = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, RewardToken) {
        vm.startBroadcast();
        RewardToken rewardToken = new RewardToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(rewardToken));
        rewardToken.mint(rewardToken.owner(), AMOUNT_AIRDROPPED_PER_ADDRESS);
        IERC20(rewardToken).transfer(address(airdrop), AMOUNT_AIRDROPPED_PER_ADDRESS);
        vm.stopBroadcast();
        return (airdrop, rewardToken);
    }

    function run() external returns (MerkleAirdrop, RewardToken) {
        return deployMerkleAirdrop();
    }
}
