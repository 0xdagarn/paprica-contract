// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Base64 } from "base64-sol/base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IERC6551Registry.sol";

contract MockERC721 is ERC721 {
    using Strings for uint256;

    address public immutable implementation;
    IERC6551Registry public immutable registry;
    IERC20 public immutable token;

    uint public immutable chainId = block.chainid;
    address public immutable tokenContract = address(this);

    constructor(
        address _implementation,
        address _registry,
        address _token
    ) ERC721("MockERC721", "M721") {
        implementation = _implementation;
        registry = IERC6551Registry(_registry);
        token = IERC20(_token);
    }

    function getAccount(uint tokenId) public view returns (address) {
        return
            registry.account(
                implementation,
                chainId,
                tokenContract,
                tokenId,
                0 // salt
            );
    }

    function createAccount(uint tokenId) public returns (address) {
        return
            registry.createAccount(
                implementation,
                chainId,
                tokenContract,
                tokenId,
                0, // salt
                ""
            );
    }

    function mintAndCreateAccount(uint tokenId) public {
        _safeMint(msg.sender, tokenId);

        createAccount(tokenId);
    }

    function mint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        address tba = getAccount(tokenId);
        uint256 balance = token.balanceOf(tba);

        string[] memory uriParts = new string[](4);

        uriParts[0] = string("data:application/json;base64,");
        uriParts[1] = string(
            abi.encodePacked(
                '{"name":"Fan #',
                tokenId.toString(),
                '",',
                '"description":"Paprica are NFT owned accounts (6551) that accept Fan Token and only return it when burned.',
                '"attributes":[{"trait_type":"Balance","value":"',
                balance,
                '"}',
                '"image":"data:image/svg+xml;base64,'
            )
        );
        uriParts[2] = Base64.encode(
            abi.encodePacked(
                '<svg width="1000" height="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">',
                '<rect width="1000" height="1000" fill="hsl(',
                balance.toString(),
                ', 78%, 56%)"/>',
                '<text x="80" y="276" fill="white" font-family="Helvetica" font-size="130" font-weight="bold">',
                "Fan #",
                tokenId.toString(),
                '</text>',
                '<text x="80" y="425" fill="white" font-family="Helvetica" font-size="130" font-weight="bold">',
                " contains </text>",
                '<text x="80" y="574" fill="white" font-family="Helvetica" font-size="130" font-weight="bold">',
                balance.toString(),
                " Tokens",
                "</text>",
                "</svg>"
            )
        );
        uriParts[3] = string('"}');

        string memory uri = string.concat(
            uriParts[0],
            Base64.encode(
                abi.encodePacked(uriParts[1], uriParts[2], uriParts[3])
            )
        );

        return uri;
    }
}
