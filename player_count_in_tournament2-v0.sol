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
contract PlayerCount is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    uint256 constant private ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY)/10;
    uint private batCount;
    uint private bowlCount;
    uint private allRounderCount;

    
    address oracle = 0x6D5599265dFDe9859e38BF7023a9411390C01793;
    string constant jobId = "c5b7e3b460a04105b4123ce26b1d2d82";
    
    constructor() {
        setPublicChainlinkToken();
    }

    function submitPlayerCountRequest(string memory url,address contractAddress,bytes4 contractSelector) public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(jobId), contractAddress, contractSelector);
        
        // Set the URL to perform the GET request on
        request.add("urlBat", url);
        request.add("pathBat", "count_batsman");

        request.add("urlBowl", url);
        request.add("pathBowl", "count_bowler");

        request.add("urlARC", url);
        request.add("pathARC", "count_all_rounder");
                
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, ORACLE_PAYMENT);
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
}