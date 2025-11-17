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
        bool flag =false;
        for (uint8 i = 0; i < 3; i++) {
            if (useraddr == top3addr[i]) {
                flag = true;
                break;
            }
        }
            if (!flag) {
                uint8 minindex = 0;
                for (uint8 q = 1; q < 3; q++) {
                    if (balance[top3addr[q]] < balance[top3addr[minindex]]) {
                        minindex = q;
                    }
                }
                if (balance[useraddr] > balance[top3addr[minindex]]) {
                    top3addr[minindex] = useraddr;
                }
            }
            for (uint8 j = 0; j < 3; j++) {
                for (uint8 k = j + 1; k < 3; k++) {
                    if (balance[top3addr[j]] < balance[top3addr[k]]) {
                        (top3addr[j], top3addr[k]) = (top3addr[k], top3addr[j]);
                    }
                }
            }
        
    }

    function Top3Bank() public view returns (address[] memory result) {
        result = new address[](3);
        for (uint i = 0; i < 3; i++) {
            result[i] = top3addr[i];
        }
        return result;
    }
    modifier onlyowner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    function withdraw() public onlyowner {
        uint amount = balance[owner];
        require(balance[owner]>0,"NO Balance" );
        //结论：永远先更新状态，再进行外部调用！
         balance[owner] = 0;
        payable(owner).transfer(amount);
       
    }
}
