//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable{

    constructor() ERC20("RewardToken","RW") Ownable(msg.sender){
    } 

    function mint(address to, uint256 amount) external onlyOwner{
        _mint(to, amount);
    }
}
