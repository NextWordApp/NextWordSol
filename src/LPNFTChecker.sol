// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPNFTChecker is Ownable {
    constructor() Ownable(msg.sender) {}

    function checkData() external returns (bool isValid) {}
}
