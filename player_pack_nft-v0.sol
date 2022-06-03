// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Base64.sol";
import "./player_count_in_tournament2.sol";
import "./player_identification.sol";
import "./player_meta.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PlayerNFT is ERC721Enumerable, Ownable{

    uint public batsmanCount;
    uint public bowlerCount;
    uint public allRounderCount;

    PlayerCount internal playerCountObj;
    PlayerId internal playerIdObj;
    PlayerMeta internal playerMetaObj;

    string constant playerIdUrl = "http://34.100.132.25:8080/getPlayerId";

    string constant playerMetaUrl = "http://34.100.132.25:8080/getPlayerMeta?pid=1&key=Full%20Name";
    
    string constant playerCountUrl = "http://34.100.132.25:8080/getPlayerCount2";

    uint public playerId;
    string public playerMeta;

    struct FantasyCard { 
        string name;
        string description;
        string bowler;        
        // string batsman;
        // string allRounder;
    }

    mapping (uint256 => FantasyCard) public fantasyCards;
    constructor() ERC721("IND Fantasy", "PWA") {
        playerCountObj = PlayerCount(0x7c4BC4168e2a643BC6E7A76A3a7841B08151B22c);
        playerIdObj = PlayerId(0x540e7913b0bc7830AA7d79Cb127ccCCCbE1C41b9);
        playerMetaObj = PlayerMeta(0x54356f8360871b872eA116E1d1694ddd75010FBB);
    }


    function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
        uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
        return num;
    }

    function getPlayerCountInfo() public onlyOwner{
        playerCountObj.submitPlayerCountRequest(playerCountUrl,address(this), this.FulfillCountParameter.selector);
    }

    function mint() public payable {
        uint256 supply = totalSupply();
        require(supply + 1 <= 2);
        uint randomNo;
        // uint pid;
        string memory url;
        // for (uint256 i = 1; i <= _mintAmount; i++) {
            randomNo = randomNum(bowlerCount, block.difficulty, supply)+1;
            url = string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=Bowler"));
            playerIdObj.submitPlayerIdRequest(url,address(this),this.FulfillIdParameter.selector);
            // pid = getRequestId();
            url = string(abi.encodePacked(playerMetaUrl,"?pid=",Strings.toString(playerId),"key=Full%20Name"));
            playerMetaObj.submitPlayerMetaRequest(url,"Full Name",address(this),this.FulfillMetaParameter.selector);
            // string memory bowlerName = getPlayerMeta();

            // randomNo = randomNum(batsmanCount, block.difficulty, supply);
            // url = string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=Batsman"));
            // playerId.createPlayerIdRequest(url,playerIdJobId,playerIdOracle);
            // pid = playerId.getRequestResult();
            // url = string(abi.encodePacked(playerMetaUrl,"?pid=",Strings.toString(pid),"key=Full%20Name"));
            // playerMeta.createPlayerMetaRequest(url,"Full Name",playerMetaJobId,playerMetaOracle);
            // string memory batsmanName = playerMeta.getRequestResult();

            // randomNo = randomNum(allRounderCount, block.difficulty, supply);
            // url = string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=All-Rounder"));
            // playerId.createPlayerIdRequest(url,playerIdJobId,playerIdOracle);
            // pid = playerId.getRequestResult();
            // url = string(abi.encodePacked(playerMetaUrl,"?pid=",Strings.toString(pid),"key=Full%20Name"));
            // playerMeta.createPlayerMetaRequest(url,"Full Name",playerMetaJobId,playerMetaOracle);
            // string memory allRounderName = playerMeta.getRequestResult();

            FantasyCard memory newcard = FantasyCard(
            string(abi.encodePacked('PWA #', uint256(supply + 1))), 
            "Play and Earn",
            playerMeta);//bowlerName,bowlerName);
            // batsmanName,
            // allRounderName);
        
            fantasyCards[supply + 1] = newcard;
            _safeMint(msg.sender, supply + 1);
        // }
        
        if (msg.sender != owner()) {
        require(msg.value >= 0.005 ether);
        }
        
        _safeMint(msg.sender, supply + 1);
    }

    function buildImage(uint256 _tokenId) public view returns(string memory) {
        FantasyCard memory currentCard = fantasyCards[_tokenId];
        return Base64.encode(bytes(
            abi.encodePacked(
                '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
                '<rect height="500" width="500" fill="hsl(20%, 50%, 25%)"/>',
                '<text x="50%" y="50%" dominant-baseline="middle" fill="hsl(30%, 100%, 80%)" text-anchor="middle" font-size="41"><tspan x="0" dy="15">',currentCard.bowler,'</tspan></text>',
                '</svg>'
            )
        ));
    }
    
    function buildMetadata(uint256 _tokenId) public view returns(string memory) {
        FantasyCard memory currentCard = fantasyCards[_tokenId];
        return string(abi.encodePacked(
                'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                            '{"name":"', 
                            currentCard.name,
                            '", "description":"', 
                            currentCard.description,
                            '", "image": "', 
                            'data:image/svg+xml;base64,', 
                            buildImage(_tokenId),
                            '"}')))));
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
        return buildMetadata(_tokenId);
    }

    function FulfillMetaParameter(bytes32 _requestId, bytes memory data) public
    {
        playerMeta = string(data);
    }

    function FulfillIdParameter(bytes32 _requestId, uint256 data) public
    {
        playerId = data;
    }

    function FulfillCountParameter(bytes32 _requestId, uint256 data, uint256 data2, uint256 data3) public
    {
        batsmanCount = data;
        bowlerCount = data2;
        allRounderCount = data3;
    }

    function withdraw() public payable onlyOwner {
        // This will pay Naman 5% of the initial sale.
        // =============================================================================
        (bool hs, ) = payable(0x7820468427997717c0dAD39fe33A4804bA967Ae8).call{value: address(this).balance * 5 / 100}("");
        require(hs);
        // =============================================================================
        
        // This will payout the owner 95% of the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }
    
}