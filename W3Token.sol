// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract W3Token is AccessControl, ERC20, ERC20Burnable {
    bytes32 public constant SWAP_ROLE = keccak256("SWAP_ROLE");
    uint256 public constant MAX_SUPPLY = 100_000_000_000e9; // max supply

    mapping(address => uint256) public lastRequestBlock;

    constructor(address owner_,string memory name_,string memory symbol_) ERC20(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
        
        _mint(owner_, MAX_SUPPLY);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        
        if (to != address(0) && hasRole(SWAP_ROLE, from) ) 
        {
            require(block.number - lastRequestBlock[to] > 3, "request too fast");
            lastRequestBlock[to] = block.number;
        }
        if (hasRole(SWAP_ROLE, to)){
            require(block.number - lastRequestBlock[from] > 3, "request too fast");
            lastRequestBlock[from] = block.number;
        }
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

}
