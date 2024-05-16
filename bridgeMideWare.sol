// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function burn(uint256 amount) external ;
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external;
}
contract bridgeMideWare is AccessControl {
    
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");
    address public token;
    address public erc20handler;
    uint16 public fee;
    address public beneficiary;
    constructor(address _token) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        token = _token;
        fee = 0;
    }
    function setERC20handler(address to) public  onlyRole(DEFAULT_ADMIN_ROLE){
        erc20handler = to;
    }
    function setFee(uint16 _fee) public  onlyRole(DEFAULT_ADMIN_ROLE){
        fee=_fee;
    }
    function setBeneficiary(address to) public onlyRole(DEFAULT_ADMIN_ROLE){
        beneficiary=to;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public{
        require(to==erc20handler,"caller is not handler");
        uint256 total = amount*(1000+fee)/1000;
        uint256 allowance = IERC20(token).allowance(from,address(this));
        require(total<=allowance,"amount error");
        if(fee>0) IERC20(token).transferFrom(from, beneficiary, total-amount);
        IERC20(token).transferFrom(from, address(this), amount);
    }
    function transfer(address to, uint256 amount)
        public
        returns (bool)
    {
        require(msg.sender == erc20handler,"caller is not handler");
        IERC20(token).transfer(to, amount);
        return true;
    }
    function burnLock(uint256 amount) public onlyRole(BURN_ROLE){
        IERC20(token).burn(amount);
    }  

}
