// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";


struct LearningProgress {
    uint256 id; // No.
    uint256 wordNum; // 已学单词量
    uint256 ctime; // 开始时间
    uint256 uptime; // 最后一次学习活动的日期
}

event LPTracker_WordNumChanged(address indexed _user, uint16 indexed _wordNum);

contract LPTracker is Ownable {
    constructor() Ownable(msg.sender) {
        s_nextId = 1;
    }

    uint256 private s_nextId = 0;
    mapping(address user => LearningProgress) private s_UserLearningProgresses;

    function addRecord(uint16 wordNums) public {
        LearningProgress storage lp = s_UserLearningProgresses[msg.sender];
        if (lp.id <= 0) {
            lp.
        }
    }
}
