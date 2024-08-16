// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RDFCoinInter.sol";

contract RebellionDataFunder {
    // IERC20接口
    DataPunkCoinInter public dataPunkCoinInter;

    // 任务结构体
    struct Task {
        uint256 taskId;
        string taskName;
        address publisher;
        uint256 reward;
        Dataset[] datasets;
    }

    // 单一数据集结构体
    struct Dataset {
        uint256 datasetId;
        address uploader;
        bool isValidated;
        address validator;
    }

    // 数据集数组
    Task[] private tasks;
    Dataset[] private datasets;

    constructor() {
        dataPunkCoinInter = new DataPunkCoinInter();
    }

    function getTask(uint256 taskId) public view returns (uint256, string memory, address, uint256, Dataset[] memory) {
        Task storage task = tasks[taskId];
        return (task.taskId, task.taskName, task.publisher, task.reward, task.datasets);
    }

    // 商户 设定任务和奖励
    function deployTask(string memory name, uint256 reward) public returns (uint256) {
        uint256 taskId;
        if (tasks.length == 0) {
            taskId = 0;
        } else {
            taskId = tasks.length;
        }

        // 初始化一个新的 Task 结构体
        Task storage newTask = tasks.push();

        newTask.taskId = taskId;
        newTask.taskName = name;
        newTask.publisher = msg.sender;
        newTask.reward = reward;

        return taskId;
    }

    // 管理员 处理质疑
    function raiseChallenge(uint256 amount, uint256 taskId, uint256 datasetId, bool challengeStatus) public returns (bool) {
        Task storage task = tasks[taskId];
        Dataset storage dataset = task.datasets[datasetId];
        dataset.isValidated = challengeStatus;
        address publisher = task.publisher;
        address uploader = dataset.uploader;

        // 质疑通过
        if (challengeStatus == true) {
            // 发放奖励给uploader, validator忠诚度提升
            transferToken(uploader, amount);
        } else {
            // 扣除验证者质押ETH, 质疑者获得奖励
            transferToken(publisher, amount);
        }

        return true;
    }

    // 用户 选择任务 提交数据
    function uploadDataset(uint256 taskId) public returns (uint256) {
        uint256 datasetId;
        if (datasets.length == 0) {
            datasetId = 0;
        } else {
            datasetId = datasets.length;
        }

        // 初始化一个新的 Dataset 结构体
        Dataset storage newDataset = tasks[taskId].datasets.push();

        newDataset.datasetId = datasetId;
        newDataset.uploader = msg.sender;
        newDataset.isValidated = false;

        return datasetId;
    }

    // 验证者 验证数据集
    function verifyDataset(uint256 taskId, uint256 datasetId) public payable returns (bool) {
        Task storage task = tasks[taskId];
        Dataset storage dataset = task.datasets[datasetId];
        dataset.isValidated = true;
        dataset.validator = msg.sender;

        return true;
    }

    function transferToken(address recipient, uint256 amount) public {
        // 获取 ERC-20 合约实例
        DataPunkCoinInter token = DataPunkCoinInter(dataPunkCoinInter);

        // 调用 transfer 函数转移代币
        bool success = token.transfer(recipient, amount);
        
        require(success, "Token transfer failed");
    }

    // 新增函数，获取 DataPunkCoinInter 合约地址
    function getDataPunkCoinInterAddress() public view returns (address) {
        return address(dataPunkCoinInter);
    }
}