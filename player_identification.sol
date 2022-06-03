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
contract PlayerId is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    
    
    uint256 constant private ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY)/10;
    uint private playerId;
    
    constructor() {
        setPublicChainlinkToken();
    }

    function submitPlayerIdRequest(string memory url,string memory _jobId,address _oracle) private returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", url);
        request.add("path", "pid");
                
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
    function fulfill(bytes32 _requestId, uint data) public recordChainlinkFulfillment(_requestId)
    {
        playerId = data;
    }

    function createPlayerIdRequest(string memory url,string memory _jobId,address _oracle) public returns(uint) {
        // string memory empty = "";
        // if(keccak256(bytes(empty)) == keccak256(bytes(playerId)))
        // {
        uint requestId = uint(submitPlayerIdRequest(url,_jobId,_oracle));
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

    function getRequestResult() public view returns (uint) {
        return playerId;
    }
}
