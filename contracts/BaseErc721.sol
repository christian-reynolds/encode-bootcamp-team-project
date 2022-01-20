//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract BaseErc721 is ERC721, Ownable {

    uint256 public tokenId;
    string public baseURL;

    //whitelist merkle tree described at https://medium.com/@ItsCuzzo/using-merkle-trees-for-nft-whitelists-523b58ada3f9
    //merkle root provided by NFT creator on deployment via constructor
    bytes32 public merkleRootWhitelist;
    //record of addresses that have previously claimed the NFT
    mapping(address => bool) public whitelistClaimed;

    constructor(string memory _name, string memory _symbol, string memory _baseURL, bytes32 _merkleRoot ) ERC721(_name, _symbol) {
        tokenId = 0;
        baseURL = _baseURL;
        merkleRootWhitelist = _merkleRoot;
    }

    function claim(bytes32[] calldata _merkleProof) public {

        //verify the wallet has not already claimed a NFT
        require(!whitelistClaimed[msg.sender], "This address has already claimed the NFT");

        //verify merkle proof provided by the UI on claiming
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRootWhitelist, leaf), "Invalid proof." );

        //update claimed list
        whitelistClaimed[msg.sender] = true;

        //mint NFT and increment tokenId
        _safeMint(msg.sender, tokenId);
        tokenId+=1;
    }
    
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist");
        string memory url = baseURL;
        
        return string(abi.encodePacked('data:application/json;utf8,{"name":"', name(),' #', uint2str(_tokenId), '","image":"', url, '"}'));
    }
    //necessary to turn tokenId into a string, included from CAMP contract: https://etherscan.io/address/0xDbEc5D2c4cc329086C8353215F0F32f6Ab514C18#code
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) return "0";
        
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }

        return string(bstr);
    }
}
