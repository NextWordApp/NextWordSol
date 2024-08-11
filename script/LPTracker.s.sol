// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {LPTracker} from "../src/LPTracker.sol";

contract CounterScript is Script {
    LPTracker public lpTracker;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        lpTracker = new LPTracker();

        vm.stopBroadcast();
    }
}
