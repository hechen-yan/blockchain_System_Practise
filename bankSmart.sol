
 
//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./bank.sol";

interface Ibank{
    event Withdrawal(address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);
   function deposite() external payable;
   function withdraw() external;
 //  function _getBalance(address x)external view returns(uint256);
  // function SortDepositAmount(address x) external;
    function Top3Bank() external view returns (address[3] memory);

}
//virtual父类可以被重写
contract Bank is Ibank{
    address  public admin;
    mapping(address => uint) public balance;
    address[3] public topDepositors;
    constructor(){
        admin == msg.sender;
    }
    function deposite() external payable virtual{
        _Deposite();       
    }
    receive()external payable virtual{
        _Deposite();
    }
    function _Deposite() internal{
        balance[msg.sender]+=msg.value;
        SortDepositAmount(msg.sender);
    }
    function SortDepositAmount(address useraddr) internal { 
          bool flag = false;
        uint8 emptySlot = type(uint8).max; // 在函数内部定义
        
        for (uint8 i = 0; i < 3; i++) {
            if (topDepositors[i] == useraddr) {
                flag = true;
                break;
            }
            // 记录第一个空位置
            if (topDepositors[i] == address(0) && emptySlot == type(uint8).max) {
                emptySlot = i;
            }
        }
        
        if (!flag) {
            // 如果有空位置，直接加入
            if (emptySlot != type(uint8).max) {
                topDepositors[emptySlot] = useraddr;
            } else {
                // 没有空位置，找到最小值比较
                uint8 minindex = 0;
                for (uint8 q = 1; q < 3; q++) {
                    if (_getBalance(topDepositors[q]) < _getBalance(topDepositors[minindex])) {
                        minindex = q;
                    }
                }
                if (balance[useraddr] > _getBalance(topDepositors[minindex])) {
                    topDepositors[minindex] = useraddr;
                }
            }
        }
        
        // 排序（使用 _getBalance 处理零地址）
        for (uint8 j = 0; j < 3; j++) {
            for (uint8 k = j + 1; k < 3; k++) {
                if (_getBalance(topDepositors[j]) < _getBalance(topDepositors[k])) {
                    (topDepositors[j], topDepositors[k]) = (topDepositors[k], topDepositors[j]);
                }
            }
        }
    }

    
    function _getBalance(address addr) public view returns (uint256) {
            if (addr == address(0)) return 0;
        return balance[addr];
    }
    
       
    function Top3Bank() external view returns (address[3] memory) { return topDepositors;}
    
    function withdraw() external {
        require(msg.sender==admin, "Only admin can withdraw");
        uint balances = address(this).balance;
        require(balances > 0, "No balance to withdraw");
        (bool sucess, bytes memory data) = admin.call{value:balances}("");
        require(sucess, "Withdrawal failed");  
        }

}

//继承Bank
contract BigBank is Bank {
    address public immutable owner;
    constructor() {
        owner = msg.sender;
    }
    modifier depositLimt(){
        require(msg.value>0.01 ether, "Deposit amount must be greater than 0.001 ether");
        _;
    }
    function deposite()external payable override depositLimt{
        _Deposite();       
    }
    receive() external override payable depositLimt {
         _Deposite();
    }
    function changeAdmin(address newadmin) external{
        require(msg.sender == owner, "Only owner can change admin");
        require(newadmin!=address(0),"admin address cant be zero");
        admin =newadmin;
    }
}


//Admin
contract Admain{
    address public immutable admin;
    constructor (){
        admin =msg.sender;
        }
     receive() external payable {}
     function adminWithdraw(Ibank b)external{
        require(msg.sender==admin,"Only admin can withdraw");
        b.withdraw();
     }
     function withdrawerTOOwner()external{
        require(msg.sender == admin, "Only admin can withdraw");
        uint256 balance = address(this).balance;
        require(balance>0,"No balance to withdraw");
        (bool flag,) = admin.call{value:balance}("");
        require(flag,"Withdrawal failed");

     }

}