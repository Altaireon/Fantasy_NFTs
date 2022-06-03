
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract PlayerCount is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    uint256 constant private ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY;
    uint private playerCount;
    address oracle = 0x6D5599265dFDe9859e38BF7023a9411390C01793;
    string constant jobId = "c5b7e3b460a04105b4123ce26b1d2d82";
    constructor() {
        setPublicChainlinkToken();
    }

    function submitPlayerCountRequest(string memory url,address contractAddress,bytes4 functionSelector) public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(jobId), contractAddress, functionSelector);
        
        // Set the URL to perform the GET request on
        request.add("get", url);
        request.add("path", "count");
                
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