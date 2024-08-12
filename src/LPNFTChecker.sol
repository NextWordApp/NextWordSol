// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import {FunctionsClient} from "@chainlink/contracts/v0.8/functions/v1_3_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


error LPNFTChecker__UnexpectedRequestID(bytes32 requestId);
event LPNFTChecker__Response(bytes32 indexed requestId, bytes response, bytes err);

contract LPNFTChecker is FunctionsClient, Ownable {
    using FunctionsRequest for FunctionsRequest.Request;

    /////////////
    // records //
    /////////////
    bytes32 private s_lastRequestId;
    bytes private s_lastResponse;
    bytes private s_lastError;


    //////////////////
    // pre-settings //
    //////////////////
    // https://docs.chain.link/chainlink-functions/supported-networks
    uint32 private s_gasLimit = 300000;

    bytes32 private constant s_donID = 0x66756e2d617262697472756d2d7365706f6c69612d3100000000000000000000;
    address private constant s_router = 0x234a5fb5Bd614a7AA2FfAB244D603abFA0Ac5C5C;
    bytes private s_encryptedSecretsUrls = "https://01.functions-gateway.testnet.chain.link/";
    uint8 private s_donHostedSecretsSlotID;
    uint64 private s_donHostedSecretsVersion;

    uint64 private immutable s_subscriptionId = 168;

    constructor(uint64 _subscriptionId) FunctionsClient(s_router) Ownable(msg.sender) 
    {
        s_subscriptionId = _subscriptionId;
    }

    string private s_Source = 
        "const characterId = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
          "url: `https://swapi.info/api/people/${characterId}/`,"
        "});"
        "if (apiResponse.error) {"
          "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data.name);";


    ///////////////
    // Functions //
    ///////////////

    //
    function checkData() external returns (bool isValid) {

    }

    /**
     * @notice Send a simple request
     * @param args List of arguments accessible from within the source code
     * @param bytesArgs Array of bytes arguments, represented as hex strings
     */
    function sendRequest(
        string[] calldata args,
        bytes[] calldata bytesArgs
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_Source);
        if (s_encryptedSecretsUrls.length > 0)
            req.addSecretsReference(s_encryptedSecretsUrls);
        else if (s_donHostedSecretsVersion > 0) {
            req.addDONHostedSecrets(
                s_donHostedSecretsSlotID,
                s_donHostedSecretsVersion
            );
        }
        if (args.length > 0) req.setArgs(args);
        if (bytesArgs.length > 0) req.setBytesArgs(bytesArgs);
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            s_subscriptionId,
            s_gasLimit,
            s_donID
        );
        return s_lastRequestId;
    }

    ////////////
    // Getter //
    ////////////
    function getLastRequestId() public view returns (bytes32 requestId) {
        requestId = s_lastRequestId;
    }

    function getLastResponse() public view returns (bytes memory lastResponse) {
        lastResponse = s_lastResponse;
    }

    function getLastError() public view returns (bytes memory lastError) {
        lastError = s_lastError;
    }


    ////////////
    // Setter //
    ////////////
    function setSource(string calldata _source) public onlyOwner {
       s_Source = _source;
    }

    function setDonHostedSecretsData(
        bytes calldata _encryptedSecretsUrls, 
        uint64 _secretsVersion,
        uint8 _secretsSlotID
    ) public onlyOwner 
    {
        s_encryptedSecretsUrls = _encryptedSecretsUrls;
        s_donHostedSecretsVersion = _secretsVersion;
        s_donHostedSecretsSlotID = _secretsSlotID;
    }

    //////////////
    // Override //
    //////////////
    /**
     * @notice Store latest result/error
     * @param requestId The request ID, returned by sendRequest()
     * @param response Aggregated response from the user code
     * @param err Aggregated error from the user code or from the execution pipeline
     * Either response or error parameter will be set, but never both
     */
    function _fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) override internal {
        if (s_lastRequestId != requestId) {
            revert LPNFTChecker__UnexpectedRequestID(requestId);
        }
        s_lastResponse = response;
        s_lastError = err;
        emit LPNFTChecker__Response(requestId, s_lastResponse, s_lastError);
    }
}
