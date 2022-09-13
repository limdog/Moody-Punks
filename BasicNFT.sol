// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";

contract BasicNFT is ERC721, Ownable {
    using Strings for uint256;

    string private TOKEN_URI_HAPPY =
        "ipfs://QmeSCxGe31h7UWRRyybLE95W1R5s3UyPTMvStrCzwdh9tU/";
    string private TOKEN_URI_UNHAPPY =
        "ipfs://QmXp19sp5BAKZJUf5Hr1iG3jJtQCRN683QWdpBe22qBMkv/";
    string public uriSuffix = "";
    uint256 private s_tokenCounter = 0;
    uint256 public lastTimestamp = block.timestamp;
    uint256 public interval = 1200;
    int256 public yesterdaysValue = 1500;

    AggregatorV3Interface internal immutable i_priceFeed =
        AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);

    constructor() ERC721("MoodyPunk", "MP") {}

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        // require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        int256 ethPriceUSD = price / 100000000;
        string memory uriPrefix = TOKEN_URI_UNHAPPY;
        if (ethPriceUSD >= yesterdaysValue) {
            uriPrefix = TOKEN_URI_HAPPY;
        }
        return
            bytes(uriPrefix).length > 0
                ? string(
                    abi.encodePacked(uriPrefix, _tokenId.toString(), uriSuffix)
                )
                : "";
    }

    function performUpkeep() public {
        // block timestamp is a uint256  in seconds since the epoch
        require(block.timestamp > lastTimestamp + interval);
        lastTimestamp = block.timestamp;
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        int256 ethPriceUSD = price / 100000000;
        yesterdaysValue = ethPriceUSD;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function setUnhappyURI(string memory svgUnhappyURI) public onlyOwner {
        TOKEN_URI_HAPPY = svgUnhappyURI;
    }

    function setHappyURI(string memory svgHappyURI) public onlyOwner {
        TOKEN_URI_HAPPY = svgHappyURI;
    }

    function setURISuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function setInterval(uint256 _interval) public onlyOwner {
        interval = _interval;
    }

    function mintNft() public returns (uint256) {
        s_tokenCounter = s_tokenCounter + 1;
        _safeMint(msg.sender, s_tokenCounter);
        return s_tokenCounter;
    }

    function getBlockTimestamp() public view returns (uint256) {
        // block timestamp is a uint256  in seconds since the epoch
        return block.timestamp;
    }

    function getPrice() public view returns (int256) {
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        return price;
    }
}
