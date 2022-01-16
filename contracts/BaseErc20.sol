//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseErc20 is ERC20, Ownable {
    event TotalSharesIncreased(uint256);
    event TotalSharesReduced(uint256);

    constructor(string memory _name, string memory _symbol, uint256 _supply) ERC20(_name, _symbol) {
        _mint(msg.sender, _supply);
    }

    function addShares(uint256 _quantity) public onlyOwner {
        _mint(msg.sender, _quantity);
        emit TotalSharesIncreased(_quantity);
    }

    function reduceShares(uint256 _quantity) public onlyOwner {
        _burn(msg.sender, _quantity);
        emit TotalSharesReduced(_quantity);
    }
}
