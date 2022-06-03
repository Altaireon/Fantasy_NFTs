// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract PlayerId is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    
    address oracle = 0x7f3354CD85b1d0a8e1b2ad6dad4e0716B5946497;
    string constant jobId = "1276b021f4254fd594ebd29f9ad1073a";
    uint256 constant private ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY)/10;
    
    constructor() {
        setPublicChainlinkToken();
    }

    function submitPlayerIdRequest(string memory url,address contractAddress,bytes4 contractSelector) public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(jobId), contractAddress,contractSelector);
        
        // Set the URL to perform the GET request on
        request.add("get", url);
        request.add("path", "pid");
                
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