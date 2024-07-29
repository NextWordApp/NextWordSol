// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";


/////////////
// Structs //
/////////////
struct LearningProgress {
    uint256 id; // No.
    uint256 wordNum; // 已学单词量
    uint256 ctime; // 开始时间
    uint256 uptime; // 最后一次上传记录的日期
}

/////////////
// Events  //
/////////////
event LPTracker_WordNumAdded(address indexed _user, uint16 indexed _wordNum);
event LPTracker_LearningProgressCorrected(address indexed _user, LearningProgress indexed _lp);

/////////////
// Errors  //
/////////////
error LPTracker_WordNumInvalid(uint16 _wordNum);
error LPTracker_UserNotFound(address _user);

//////////////
// Contract //
//////////////
contract LPTracker is Ownable {

    uint256 private s_nextId = 0;
    mapping(address user => LearningProgress) private s_UserLearningProgresses;


    ///////////
    // Funcs //
    ///////////
    constructor() Ownable(msg.sender) {
        s_nextId = 1;
    }


    // Add/update new word learning prgress. 
    function updateProgress(uint16 wordNum) public {
        if ( wordNum <= 0 ){
            revert LPTracker_WordNumInvalid(wordNum);
        }

        LearningProgress storage lp = s_UserLearningProgresses[msg.sender];

        if (lp.id <= 0) {
            lp.ctime= block.timestamp;
            lp.id = s_nextId;
            s_nextId++;
        }

        uint256 latestWordNum = lp.wordNum;
        uint256 totalWordNum = latestWordNum + uint256(wordNum);
        lp.wordNum = totalWordNum;
        lp.uptime =  block.timestamp;

        emit LPTracker_WordNumAdded(msg.sender, wordNum);
    }

    /*
    CRUD
     */

    // Get the Learning progress by the User address
    function getProgressByUser(address user) public view returns (LearningProgress memory learningProgress) 
    {
        learningProgress = s_UserLearningProgresses[user];
        if (learningProgress.id <= 0) {
            revert LPTracker_UserNotFound(user);
        }
        return learningProgress;
    }

    function correctLearningProgress(address user,uint32 wordNum,uint256 uptime) external onlyOwner {
        LearningProgress storage lp = s_UserLearningProgresses[user];

        if (lp.id <= 0) {
             revert LPTracker_UserNotFound(user);
        }

        lp.wordNum = wordNum;
        lp.uptime = uptime;
        
        emit LPTracker_LearningProgressCorrected(user,lp);
    }

    // Check user exists or not
    function _checkUserExists(address _user) internal view returns (bool _exists) {
        LearningProgress memory learningProgress =  s_UserLearningProgresses[_user];
         if (learningProgress.id <= 0) {
           return false;
        }
        return true;
    }

}
