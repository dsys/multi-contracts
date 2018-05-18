pragma solidity ^0.4.23;

import "../Service.sol";

contract MockService is Service {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.MockService");

    function name() external view returns (string) {
        return "MockService";
    }

    function serviceMetadata() external view returns (string) {
        return "example.com";
    }

    function supportsInterface(bytes32 _interfaceHash) external view returns (bool) {
        return
            _interfaceHash == Service.InterfaceHash ||
            _interfaceHash == MockService.InterfaceHash;
    }

}
