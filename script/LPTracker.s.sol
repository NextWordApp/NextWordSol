// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {LPTracker} from "../src/LPTracker.sol";

contract LPTrackerScript is Script {
    LPTracker public s_LPTracker;

    function setUp() public {}

    function run(address _owner) public returns (LPTracker) {
        console.log("Deploying LPTracker");

        vm.startBroadcast(_owner);

        s_LPTracker = new LPTracker();

        vm.stopBroadcast();
        return s_LPTracker;
    }
}
