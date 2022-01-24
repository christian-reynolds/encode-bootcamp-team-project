//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseErc20 is ERC20, Ownable {
    uint256 public totalDividends;
    mapping(address => uint256) private _lastDividends;

    event TotalSharesIncreased(uint256 indexed);
    event TotalSharesReduced(uint256 indexed);
    event DividendClaimed(address indexed, uint256 indexed);

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

    function depositDividends() public payable onlyOwner {
        totalDividends += msg.value;
    }

    function dividendBalanceOf(address account) public view returns (uint256) {
        uint256 newDividends = totalDividends - _lastDividends[account];
        uint256 product = balanceOf(account) * newDividends;

        return product / totalSupply();
    }

    function claimDividend() public {
        uint256 dividendOwed = dividendBalanceOf(msg.sender);
        require(dividendOwed > 0, "No dividend owed");

        _lastDividends[msg.sender] = totalDividends;
        (bool success, ) = payable(msg.sender).call{value: dividendOwed}("");
        require(success, "Error claiming dividend");
    
        emit DividendClaimed(msg.sender, dividendOwed);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override  {
        require(
            dividendBalanceOf(sender) == 0 && dividendBalanceOf(recipient) == 0,
            "Both parties must claim dividends before any transfer"
        );

        ERC20._transfer(sender, recipient, amount);

        _lastDividends[recipient] = totalDividends;
    }

    receive() external payable {
        depositDividends();
    }
}
