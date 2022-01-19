//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract BaseErc721 is ERC721, Ownable {

    uint256 public tokenId;
    string public ipfsCID;

    //whitelist merkle tree described at https://medium.com/@ItsCuzzo/using-merkle-trees-for-nft-whitelists-523b58ada3f9
    //merkle root provided by NFT creator on deployment via constructor
    bytes32 public merkleRootWhitelist;
    //record of addresses that have previously claimed the NFT
    mapping(address => bool) public whitelistClaimed;

    event tokenMinted(uint256, address);


    constructor(string memory _name, string memory _symbol, string memory _ipfsCID, bytes32 _merkleRoot ) ERC721(_name, _symbol) {
        tokenId = 0;
        ipfsCID = _ipfsCID;
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
    
}
