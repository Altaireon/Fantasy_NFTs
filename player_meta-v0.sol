// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract PlayerMeta is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    
    uint256 constant private ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY)/10;
    address oracle = 0x6D5599265dFDe9859e38BF7023a9411390C01793;
    string jobId = "1160b7badd93472fa813bb16ddb41e80";
    constructor() {
        setPublicChainlinkToken();
    }

    function submitPlayerMetaRequest(string memory url,string memory key,address contractAddress, bytes4 contractSelector) public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(jobId), contractAddress, contractSelector);
        
        // Set the URL to perform the GET request on
        string memory url2 = string(url);
        request.add("get", url2);
        // request.add("path", "info,Mat_Bat");
        // string memory url3 = string(abi.encodePacked(url,"&key=Mat_Bowl"));
        // request.add("get", url3);
        request.add("path", string(abi.encodePacked("info,",key)));
                
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
}