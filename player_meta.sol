// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
//  Player
// Span_Bowl
// Mat_Bowl
// Inns_Bowl
// Overs
// Mdns
// Runs_Bowl
// Wkts
// BBI
// Ave_Bowl
// Econ
// SR_Bowl
// 4
// 5
// Unnamed: 14
// Span_Bat
// Mat_Bat
// Inns_Bat
// NO
// Runs_Bat
// HS
// Ave_Bat
// BF
// SR_Bat
// 100
// 50
// 0
// 4s
// 6s
// Unnamed: 15
// Span
// Mat
// Inns
// Dis
// Ct
// St
// Ct Wk
// Ct Fi
// MD
// D/I
contract PlayerMeta is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    
    uint256 constant private ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY)/10;
    bytes public playerMeta;
    string public playerString;
    
    constructor() {
        setPublicChainlinkToken();
    }

    function submitPlayerMetaRequest(string memory url,string memory key,string memory _jobId,address _oracle) private returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillMultipleParameter.selector);
        
        // Set the URL to perform the GET request on
        string memory url2 = string(url);
        request.add("get", url2);
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
        playerMeta = data;
        playerString = string(playerMeta);
    }

    function bytesToBytes32Array(bytes memory data)
    public
    pure
    returns (bytes32[] memory)
    {
        // Find 32 bytes segments nb
        uint256 dataNb = data.length / 32;
        // Create an array of dataNb elements
        bytes32[] memory dataList = new bytes32[](dataNb);
        // Start array index at 0
        uint256 index = 0;
        // Loop all 32 bytes segments
        for (uint256 i = 32; i <= data.length; i = i + 32) {
            bytes32 temp;
            // Get 32 bytes from data
            assembly {
                temp := mload(add(data, i))
            }
            // Add extracted 32 bytes to list
            dataList[index] = temp;
            index++;
        }
        // Return data list
        return (dataList);
    }

    function createPlayerMetaRequest(string memory url,string memory key,string memory _jobId,address _oracle) public returns(uint) {
        // string memory empty = "";
        // if(keccak256(bytes(empty)) == keccak256(bytes(playerId)))
        // {
        uint requestId = uint(submitPlayerMetaRequest(url,key,_jobId,_oracle));
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

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
    function getRequestResult() public view returns (string memory) {
        return playerString;
    }
}
