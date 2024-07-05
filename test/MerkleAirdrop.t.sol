//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public airdrop;
    RewardToken public token;

    bytes32 public merkle_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 public PROOF_ONE = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    address user;
    bytes32[] public PROOF = [PROOF_ONE, PROOF_TWO];
    uint256 userPrivKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            //deploy with our scripts
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            //foundry doesnt support zksync scripts for now
            token = new RewardToken();
            airdrop = new MerkleAirdrop(merkle_ROOT, token);

            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
            (user, userPrivKey) = makeAddrAndKey("user");
        }
    }

    function testUsersCanClaim() public {
        //We will take the user generated from makeAddrAndKey function and put him in input json
        //by putting the address in GenerateInput Script
        //Function is predictable and always the same.
        // console.log("user address:", user);

        uint256 startingBalance = token.balanceOf(user);
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);

        uint256 endingBalance = token.balanceOf(user);
        console.log("user endingBalance:", endingBalance);
        console.log("user startingBalance:", startingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
