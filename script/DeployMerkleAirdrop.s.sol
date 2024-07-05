//SPDX-License-Identifier:MIT

pragma solidity ^0.8.26;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToAirdropPerAddress = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, RewardToken) {
        vm.startBroadcast();
        RewardToken token = new RewardToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToAirdropPerAddress);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, RewardToken) {
        return deployMerkleAirdrop();
    }
}
