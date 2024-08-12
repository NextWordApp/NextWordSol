// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {LPTracker,LearningProgress} from "../src/LPTracker.sol";
import {LPTrackerScript} from "../script/LPTracker.s.sol";

event LPTracker_WordNumAdded(address indexed _user, uint16 indexed _wordNum);

contract LPTrackerTest is Test {
    address public OWNER = vm.addr(6433);
    address public USER = vm.addr(87);
    LPTracker private s_LPTracker;

    function setUp() external {
        vm.deal(OWNER, 100 ether);
        vm.deal(USER, 0.02 ether);
        LPTrackerScript deployer = new LPTrackerScript();
        s_LPTracker = deployer.run(OWNER);
    }

    function test_LPTracker_AddUserProgress(uint16 wordNum) public {
        vm.assume(wordNum != 0);
        vm.startPrank(USER);
        vm.expectEmit(true, true, false,false);
        emit LPTracker_WordNumAdded(USER, wordNum);
        s_LPTracker.updateProgress(wordNum);
        vm.stopPrank();
        LearningProgress memory learningProgress  = s_LPTracker.getProgressByUser(USER);
        console.log("--- learningProgress data: ---");
        console.log(learningProgress.id);
        console.log(learningProgress.wordNum);
        console.log("------------------------------");
        assertEq(1,learningProgress.id);
        assertEq(wordNum,learningProgress.wordNum);
    }

   function test_LPTracker_AddUserProgressMuti(uint16 wordNum) public {
        vm.assume(wordNum != 0);
        uint16 sumOfDigits = 0; // 用于存储数字各位之和
        vm.startPrank(USER);

        // 遍历 wordNum 的每一位数字
        uint16 tempWordNum = wordNum; // 使用临时变量存储原始数值
        while (tempWordNum > 0) {
            skip(3600); // Skips forward block.timestamp by the specified number of seconds.
            uint16 digit = tempWordNum % 10; // 获取当前最低位的数字

            if (digit == 0) {
                sumOfDigits += digit; // 计算各位数字之和
                tempWordNum /= 10; // 移除当前最低位的数字
                continue;
            }

            vm.expectEmit(true, true, false, false);
            emit LPTracker_WordNumAdded(USER, digit); // 发出事件

            s_LPTracker.updateProgress(digit); // 更新进度

            sumOfDigits += digit; // 计算各位数字之和
            tempWordNum /= 10; // 移除当前最低位的数字
        }

        vm.stopPrank();

        LearningProgress memory learningProgress = s_LPTracker.getProgressByUser(USER);
        console.log("--- learningProgress data: ---");
        console.log(learningProgress.id);
        console.log(learningProgress.wordNum);
        console.log("------------------------------");

        // 检查 learningProgress.id 是否为 1
        assertEq(1, learningProgress.id);
        // 检查 learningProgress.wordNum 是否等于 wordNum 各位之和
        assertEq(sumOfDigits, learningProgress.wordNum);
    }
}
