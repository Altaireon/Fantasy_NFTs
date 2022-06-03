// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PlayerNFT is ERC721Enumerable, Ownable, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint public batsmanCount;
    uint public bowlerCount;
    uint public allRounderCount;

    uint256 constant private ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY)/10;

    // string constant playerIdUrl = "http://34.100.132.25:8080/getPlayerId";
    // string constant playerIdJobId = "1276b021f4254fd594ebd29f9ad1073a";
    // address constant playerIdOracle = 0x7f3354CD85b1d0a8e1b2ad6dad4e0716B5946497;

    string constant playerMetaUrl = "http://34.100.132.25:8080/getPlayerMeta?pid=1&key=Full%20Name";
    string constant playerMetaJobId = "1160b7badd93472fa813bb16ddb41e80";
    address constant playerMetaOracle = 0x6D5599265dFDe9859e38BF7023a9411390C01793;
    
    string constant playerCountUrl = "http://34.100.132.25:8080/getPlayerCount2";
    string constant playerCountJobId = "c5b7e3b460a04105b4123ce26b1d2d82";

    // uint private playerId;
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
        setPublicChainlinkToken();
    }

    // function submitPlayerIdRequest(string memory url,string memory _jobId,address _oracle) private returns (bytes32 requestId) 
    // {
    //     Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfill.selector);
        
    //     // Set the URL to perform the GET request on
    //     request.add("get", url);
    //     request.add("path", "pid");
                
    //     // Sends the request
    //     return sendChainlinkRequestTo(_oracle, request, ORACLE_PAYMENT);
    // }
    
    // function fulfill(bytes32 _requestId, uint data) public recordChainlinkFulfillment(_requestId)
    // {
    //     playerId = data;
    // }

    function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
        uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
        return num;
    }

    function mint() public payable {
        uint256 supply = totalSupply();
        require(supply + 1 <= 2);
        uint randomNo;
        // uint pid;
        // string memory url;
        // for (uint256 i = 1; i <= _mintAmount; i++) {
            randomNo = randomNum(bowlerCount, block.difficulty, supply)+1;
            // url = string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=Bowler"));
            // submitPlayerIdRequest(string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=Bowler")),playerIdJobId,playerIdOracle);
            // pid = getRequestId();
            // url = string(abi.encodePacked(playerMetaUrl,"?pid=",Strings.toString(playerId),"key=Full%20Name"));
            submitPlayerMetaRequest(playerMetaUrl,"Full Name",playerMetaJobId,playerMetaOracle);
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

    function submitPlayerCountRequest(string memory url,string memory _jobId,address _oracle) private returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillCount.selector);
        
        // Set the URL to perform the GET request on
        request.add("urlBat", url);
        request.add("pathBat", "count_batsman");

        request.add("urlBowl", url);
        request.add("pathBowl", "count_bowler");
    
        request.add("urlARC", url);
        request.add("pathARC", "count_all_rounder");
                
        // Sends the request
        return sendChainlinkRequestTo(_oracle, request, ORACLE_PAYMENT);
    }

    /**
     * Receive the response in the form of uint256
     */ 
    function fulfillCount(bytes32 _requestId, uint data,uint data2, uint data3) public recordChainlinkFulfillment(_requestId)
    {
        batsmanCount = data;
        bowlerCount = data2;
        allRounderCount = data3;
    }

    function createPlayerCountRequest() public returns(uint) {
        // string memory empty = "";
        // if(keccak256(bytes(empty)) == keccak256(bytes(playerId)))
        // {
        uint requestId = uint(submitPlayerCountRequest(playerCountUrl,playerCountJobId,playerMetaOracle));
        return requestId;
        // }
        // else
        // {
            // string memory url = string(abi.encodePacked(pidMetaUrl,"?id=",playerId));
            // uint requestId = uint(submitRequest(url));
            // userRequests[msg.sender].push(requestId);
            // return requestId;
        // }
    }
    
    function submitPlayerMetaRequest(string memory url,string memory key,string memory _jobId,address _oracle) private returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillMultipleParameter.selector);
        
        // Set the URL to perform the GET request on
        // string memory url2 = string(url);
        request.add("get", url);
        // request.add("path", "info,Mat_Bat");
        // string memory url3 = string(abi.encodePacked(url,"&key=Mat_Bowl"));
        // request.add("get", url3);
        request.add("path", string(abi.encodePacked("info,",key)));
                
        // Sends the request
        return sendChainlinkRequestTo(_oracle, request, ORACLE_PAYMENT);
    }
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
        return 0x0;
        }

        assembly { // solhint-disable-line no-inline-assembly
        result := mload(add(source, 32))
        }
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfillMultipleParameter(bytes32 _requestId, bytes memory data) public recordChainlinkFulfillment(_requestId)
    {
        playerMeta = string(data);
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