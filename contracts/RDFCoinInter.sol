// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入代币合约需要继承的 openzeppelin 的 ERC-20 合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RDFCoinInter is ERC20{
    // 设置小数位数为 2（例如，如果你要设置为 2 位小数）
    uint8 private _decimals = 2;

    // 构造函数，调用了 openzeppelin 的 ERC-20 合约的构造函数，传入代币名称和符号
    constructor() ERC20("DataPunk Coin", "DPC") {
        // 铸造 100 个 DPC 给合约部署者
        _mint(msg.sender, 100 * 10**uint256(_decimals));
    }

    // 覆盖 ERC20 合约的 decimals 函数
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}