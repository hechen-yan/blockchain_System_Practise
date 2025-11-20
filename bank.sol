//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    receive() external payable {
        balance[msg.sender] += msg.value;
        SortDepositAmount(msg.sender); 
    }
    mapping(address => uint256) public balance;
    address[3] public top3addr;
    address public owner;
    
    constructor()  {
        owner = msg.sender;
    }

    function deposite() public payable {
        balance[msg.sender] += msg.value;
        SortDepositAmount(msg.sender);
    }

    function SortDepositAmount(address useraddr) internal {
        bool flag = false;
        uint8 emptySlot = type(uint8).max; // 在函数内部定义
        
        for (uint8 i = 0; i < 3; i++) {
            if (top3addr[i] == useraddr) {
                flag = true;
                break;
            }
            // 记录第一个空位置
            if (top3addr[i] == address(0) && emptySlot == type(uint8).max) {
                emptySlot = i;
            }
        }
        
        if (!flag) {
            // 如果有空位置，直接加入
            if (emptySlot != type(uint8).max) {
                top3addr[emptySlot] = useraddr;
            } else {
                // 没有空位置，找到最小值比较
                uint8 minindex = 0;
                for (uint8 q = 1; q < 3; q++) {
                    if (_getBalance(top3addr[q]) < _getBalance(top3addr[minindex])) {
                        minindex = q;
                    }
                }
                if (balance[useraddr] > _getBalance(top3addr[minindex])) {
                    top3addr[minindex] = useraddr;
                }
            }
        }
        
        // 排序（使用 _getBalance 处理零地址）
        for (uint8 j = 0; j < 3; j++) {
            for (uint8 k = j + 1; k < 3; k++) {
                if (_getBalance(top3addr[j]) < _getBalance(top3addr[k])) {
                    (top3addr[j], top3addr[k]) = (top3addr[k], top3addr[j]);
                }
            }
        }
    }

    function _getBalance(address addr) internal view returns (uint256) {
        if (addr == address(0)) return 0;
        return balance[addr];
    }

    function Top3Bank() public view returns (address[3] memory) {
        return top3addr;
    }
    
    modifier onlyowner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function withdraw() public onlyowner {
        uint amount = balance[owner];
        require(balance[owner] > 0, "NO Balance");
        // 结论：永远先更新状态，再进行外部调用！
        balance[owner] = 0;
        payable(owner).transfer(amount);
    }
}