// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./player_count_in_tournament2.sol";
import "./player_identification.sol";
import "./player_meta.sol";
import "./Base64.sol";
// import "./RandomlyAssigned.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
// import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';

contract PlayerNFT is ERC721Enumerable, Ownable {
    uint256 public batsmanCount;
    uint256 public bowlerCount;
    uint256 public allRounderCount;

    PlayerId playerId;
    PlayerMeta playerMeta;

    string private playerIdUrl;
    string private playerMetaUrl;
    address private playerMetaOracle;
    address private playerIdOracle;
    bytes32 private playerMetaJobId;
    bytes32 private playerIdJobId;
      
    // string public baseExtension = ".json";
    uint256 public cost = 0.005 ether;
    uint256 public maxSupply = 10;
    uint256 public maxMintAmount = 2;
    bool public paused = false;

    struct FantasyCard { 
        string name;
        string description;
        string bowler;
        string batsman;
        string allRounder;
    }

    mapping (uint256 => FantasyCard) public fantasyCards;
//string memory _playerIdUrl,string memory _playerMetaUrl,address _playerMetaOracle,address _playerIdOracle,string memory _playerIdJobId,string memory _playerMetaJobId
    constructor(address _pid_address, address _pmeta_address) ERC721("IND Fantasy", "PWA") {
        playerId = PlayerId(_pid_address);
        playerMeta = PlayerMeta(_pmeta_address);
        // for (uint256 a = 1; a <= 50; a++) {
        //     mint(msg.sender);
        // }
        // playerIdUrl = _playerIdUrl;
        // playerIdOracle = _playerIdOracle;
        // playerIdJobId = _playerIdJobId;
        // playerMetaUrl = _playerMetaUrl;
        // playerMetaOracle = _playerMetaOracle;
        // playerMetaJobId = _playerMetaJobId;
    }

    function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
        uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
        
        return num;
    }

    // public
    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        if (msg.sender != owner()) {
        require(msg.value >= cost * _mintAmount);
        }
        uint randomNo;
        uint pid;
        string memory url;
        for (uint256 i = 1; i <= _mintAmount; i++) {
            randomNo = randomNum(bowlerCount, block.difficulty, supply)+1;
            url = string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=Bowler"));
            playerId.createPlayerIdRequest(url,string(abi.encodePacked(playerIdJobId)),playerIdOracle);
            pid = playerId.getRequestResult();
            url = string(abi.encodePacked(playerMetaUrl,"?pid=",Strings.toString(pid),"&key=Full%20Name"));
            playerMeta.createPlayerMetaRequest(url,"Full Name",string(abi.encodePacked(playerMetaJobId)),playerMetaOracle);
            string memory bowlerName = playerMeta.getRequestResult();

            randomNo = randomNum(batsmanCount, block.difficulty, supply)+1;
            url = string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=Batsman"));
            playerId.createPlayerIdRequest(url,string(abi.encodePacked(playerMetaJobId)),playerIdOracle);
            pid = playerId.getRequestResult();
            url = string(abi.encodePacked(playerMetaUrl,"?pid=",Strings.toString(pid),"&key=Full%20Name"));
            playerMeta.createPlayerMetaRequest(url,"Full Name",string(abi.encodePacked(playerMetaJobId)),playerMetaOracle);
            string memory batsmanName = playerMeta.getRequestResult();

            randomNo = randomNum(allRounderCount, block.difficulty, supply)+1;
            url = string(abi.encodePacked(playerIdUrl,"?index=",Strings.toString(randomNo),"&type=All-Rounder"));
            playerId.createPlayerIdRequest(url,string(abi.encodePacked(playerIdJobId)),playerIdOracle);
            pid = playerId.getRequestResult();
            url = string(abi.encodePacked(playerMetaUrl,"?pid=",Strings.toString(pid),"&key=Full%20Name"));
            playerMeta.createPlayerMetaRequest(url,"Full Name",string(abi.encodePacked(playerMetaJobId)),playerMetaOracle);
            string memory allRounderName = playerMeta.getRequestResult();

            FantasyCard memory newcard = FantasyCard(
            string(abi.encodePacked('PWA #', Strings.toString(uint256(supply + 1)))), 
            "Play and Earn",
            bowlerName,//bowlerName,bowlerName);
            batsmanName,
            allRounderName
            // allRounderName
            );
        
            fantasyCards[supply + i] = newcard;
            _safeMint(msg.sender, supply + i);
        }
    }

    function buildImage(uint256 _tokenId) public view returns(string memory) {
        FantasyCard memory currentCard = fantasyCards[_tokenId];
        return Base64.encode(bytes(
            abi.encodePacked(
                '<svg width="300" height="300" xmlns="http://www.w3.org/2000/svg">',
'<rect height="300" width="300" fill="hsl(10, 0%, 70%)"/>',
'<text x="5%" y="5%" dominant-baseline="auto" fill="hsl(0%, 0%, 0%)" font-size="10">',
'<tspan x="80" dy="1.2em">',currentCard.bowler,'</tspan>',
'<tspan x="80" dy="1.2em">',currentCard.batsman,'</tspan>',
'<tspan x="80" dy="1.2em">',currentCard.allRounder,'</tspan></text>',
'</svg>'
        )));
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

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function setPlayerCount(address _contract_address,string memory url,string memory _jobId,address _oracle) public onlyOwner {
        PlayerCount playerCount = PlayerCount(_contract_address);
        playerCount.createPlayerCountRequest(url,_jobId,_oracle);
        batsmanCount = playerCount.getRequestResult();
        bowlerCount = playerCount.getRequestResult2();
        allRounderCount = playerCount.getRequestResult3();
    }
    
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setPlayerId_Info(string memory _url,string memory _jobId, address _oracle) public onlyOwner {
        playerIdUrl = _url;
        playerIdJobId = stringToBytes32(_jobId);
        playerIdOracle = _oracle;
    }
    
    function setPlayerMeta_Info(string memory _url,string memory _jobId, address _oracle) public onlyOwner {
        playerMetaUrl = _url;
        playerMetaJobId = stringToBytes32(_jobId);
        playerMetaOracle = _oracle;
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

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
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
