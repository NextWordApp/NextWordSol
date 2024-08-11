// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract LPCertNFT is ERC721, Ownable {
    // 自定义错误用于更明确的错误处理
    error LPCertNFT__InvalidMilestone(uint256 milestone);
    error LPCertNFT__MaximumSupplyReached(uint256 milestone, uint16 maxSupply);
    error LPCertNFT__OnlyOwnerOrAuthorized(address operator);

    // NFT铸造事件
    event NFTMinted(
        uint256 indexed tokenId,
        address indexed owner,
        uint256 indexed milestone,
        uint16 holderRank
    );

    // 变量定义
    uint256 private s_tokenCounter; // 已经铸造的NFT总数
    uint16 private s_defaultMaxSupply; // 每个里程碑的默认最大供应量
    uint256[] private s_milestones; // 设定的学习进度里程碑: 用户在学习到一定数量的英语单词时（如100, 1000, 3000, 5000, 8000, 9999）

    // 映射定义
    mapping(uint256 => string) private s_tokenIdToURI; // 每个NFT的URI
    mapping(uint256 => uint16) private s_maxSupplyMilestoneNFT; // 每个里程碑的最大NFT数量
    mapping(uint256 => uint16) private s_numMilestoneNFT; // 每个里程碑当前已经铸造的NFT数量
    mapping(address => uint256[]) private s_userMilestones; // 用户拥有的里程碑记录

    // 构造函数，初始化里程碑和默认最大供应量
    constructor(
        uint256[] memory _milestones,
        uint16 _defaultMaxSupply
    ) ERC721("English Learning Milestone NFT", "ELMNFT") Ownable(msg.sender) {
        s_tokenCounter = 0;
        s_milestones = _milestones;
        s_defaultMaxSupply = _defaultMaxSupply;
        _setMilestonesMaxSupply(_milestones, _defaultMaxSupply);
    }

    // 验证给定的单词数量是否达到了有效的里程碑
    function _isValidMilestone(
        address _user,
        uint256 _wordCount
    ) private view returns (bool) {
        uint256 _floorMilestone = _getFloorMilestone(_wordCount);
        uint256[] memory _userMilestones = s_userMilestones[_user];
        for (uint i = 0; i < _userMilestones.length; i++) {
            if (_userMilestones[i] == _floorMilestone) {
                return false; // 如果在用户已经 minted 的 Milestones 找到了最近的 milestone, 那就说明离下一个 milestone 还不达标
            }
        }
        return true; // 说明该 milestone 还未 mint
        // for (uint256 i = 0; i < s_milestones.length; i++) {
        //     if (s_milestones[i] <= _wordCount) {
        //         return true;
        //     }
        // }
        // return false;
    }

    // 获取用户背单词以后最近的且有效的里程碑
    function _getFloorMilestone(
        uint256 _wordCount
    ) private view returns (uint256) {
        uint256 floorMilestone = 0;
        for (uint256 i = 0; i < s_milestones.length; i++) {
            if (s_milestones[i] <= _wordCount) {
                floorMilestone = s_milestones[i];
            }
        }
        return floorMilestone;
    }

    // 公开函数，供授权者铸造NFT
    function mintNft(
        address to,
        uint256 _wordCount,
        string memory _nftURI
    ) public onlyAuthorized {
        // 验证里程碑的有效性
        if (!_isValidMilestone(to, _wordCount)) {
            revert LPCertNFT__InvalidMilestone(_wordCount);
        }

        uint256 _floorMilestone = _getFloorMilestone(_wordCount);

        // 检查是否达到最大供应量
        if (
            s_numMilestoneNFT[_floorMilestone] >=
            s_maxSupplyMilestoneNFT[_floorMilestone]
        ) {
            revert LPCertNFT__MaximumSupplyReached(
                _floorMilestone,
                s_maxSupplyMilestoneNFT[_floorMilestone]
            );
        }

        // 更新里程碑对应的NFT数量
        s_numMilestoneNFT[_floorMilestone]++;
        uint256 tokenId = s_tokenCounter;
        _safeMint(to, tokenId);

        // 记录NFT的URI及更新总铸造量
        s_tokenIdToURI[tokenId] = _nftURI;
        s_tokenCounter++;

        // 将里程碑记录添加到用户数据中
        s_userMilestones[to].push(_floorMilestone);

        // 触发NFT铸造事件
        emit NFTMinted(
            tokenId,
            to,
            _floorMilestone,
            s_numMilestoneNFT[_floorMilestone]
        );
    }

    // 内部函数，返回基础URI
    function _baseURI() internal pure override returns (string memory) {
        return "https://aquamarine-fascinating-grouse-888.mypinata.cloud/ipfs/";
    }

    // 获取特定tokenId的URI
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return string(abi.encodePacked(_baseURI(), s_tokenIdToURI[tokenId]));
    }

    /* GETTER */

    // 获取总铸造的NFT数量
    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    // 获取特定里程碑的铸造信息
    function getMilestoneInfo(
        uint256 _wordCount
    ) public view returns (uint16 minted, uint16 maxSupply) {
        uint256 _floorMilestone = _getFloorMilestone(_wordCount);

        return (
            s_numMilestoneNFT[_floorMilestone],
            s_maxSupplyMilestoneNFT[_floorMilestone]
        );
    }

    // 获取用户已达成的所有里程碑
    function getUserMilestones(
        address _user
    ) public view returns (uint256[] memory) {
        return s_userMilestones[_user];
    }

    // 获取所有的学习进度里程碑
    function getMilestones()
        public
        view
        onlyAuthorized
        returns (uint256[] memory)
    {
        return s_milestones;
    }

    /* SETTER */

    // 设置新的里程碑
    function setMilestones(uint256[] memory _milestones) public onlyAuthorized {
        s_milestones = _milestones;
    }

    // 设置或更新里程碑的最大供应量
    function _setMilestonesMaxSupply(
        uint256[] memory _milestones,
        uint16 _maxSupply
    ) internal onlyAuthorized {
        for (uint256 i = 0; i < _milestones.length; i++) {
            // if (!_isValidMilestone(_milestones[i])) {
            //     revert LPCertNFT__InvalidMilestone(_milestones[i]);
            // }
            s_maxSupplyMilestoneNFT[_milestones[i]] = _maxSupply;
        }
    }

    /* 权限控制 */

    // 定义操作员权限映射
    mapping(address => bool) internal s_authorizedOperators;

    // 修饰符，限定函数只能由合约拥有者或授权的操作员调用
    modifier onlyAuthorized() {
        if (msg.sender != owner() && !s_authorizedOperators[msg.sender]) {
            revert LPCertNFT__OnlyOwnerOrAuthorized(msg.sender);
        }
        _;
    }

    // 添加授权操作员
    function addAuthorizedOperator(address _operator) external onlyOwner {
        s_authorizedOperators[_operator] = true;
    }

    // 移除授权操作员
    function removeAuthorizedOperator(address _operator) external onlyOwner {
        s_authorizedOperators[_operator] = false;
    }
}
