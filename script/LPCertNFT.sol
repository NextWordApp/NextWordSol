// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {LPCertNFT} from "../src/LPCertNFT.sol";

contract LPCertNFTScript is Script {
    LPCertNFT public s_lPCertNFT;
    uint256[] public s_milestones;
    uint16 public s_defaultMaxSupply;

    function setUp() public {
        uint16[6] memory _milestones = [100, 1000, 3000, 5000, 8000, 9999];
        for (uint i = 0; i < _milestones.length; i++) {
            s_milestones.push(_milestones[i]);
        }
        // milestones = [100, 1000, 3000, 5000, 8000, 9999];
        s_defaultMaxSupply = type(uint16).max;
    }

    function run(address _owner) public {
        console.log("SetUp LPCertNFT");
        setUp();

        console.log("Deploying LPCertNFT");
        vm.startBroadcast(_owner);

        s_lPCertNFT = new LPCertNFT(s_milestones, s_defaultMaxSupply);

        vm.stopBroadcast();
    }
}
