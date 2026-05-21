// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyNFT is ERC721Enumerable, Ownable, ERC2981 {

    uint256 public mintPrice = 0.01 ether;
    uint256 public maxSupply = 9;
    uint256 public totalMinted;

    string private baseTokenURI;

    bool public revealed = false;

    string public hiddenMetadataUri;

    mapping(address => bool) public whitelist;

    constructor(
        string memory _hiddenMetadataUri
    )
        ERC721("MyNFT", "MNFT")
        Ownable(msg.sender)
    {
        hiddenMetadataUri = _hiddenMetadataUri;

        _setDefaultRoyalty(msg.sender, 500);
    }

    function whitelistUser(address user) external onlyOwner {
        whitelist[user] = true;
    }

    function mint(uint256 quantity) external payable {

        require(whitelist[msg.sender], "Not whitelisted");

        require(totalMinted + quantity <= maxSupply, "Max supply reached");

        require(msg.value >= mintPrice * quantity, "Insufficient ETH");

        for(uint256 i = 0; i < quantity; i++) {

            uint256 tokenId = totalMinted + 1;

            _safeMint(msg.sender, tokenId);

            totalMinted++;
        }
    }

    function reveal(string memory _baseURI) external onlyOwner {
        baseTokenURI = _baseURI;
        revealed = true;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns(string memory)
    {
        require(_ownerOf(tokenId) != address(0), "Not exist");

        if(!revealed) {
            return hiddenMetadataUri;
        }

        return string(
            abi.encodePacked(
                baseTokenURI,
                Strings.toString(tokenId),
                ".json"
            )
        );
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}