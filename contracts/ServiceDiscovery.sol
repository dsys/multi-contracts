pragma solidity ^0.4.23;

import "./Service.sol";

contract ServiceDiscovery {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.ServiceDiscovery");

    function supportsService(string _key) external view returns (bool);
    function supportsService(string _key, bytes32 _interfaceHash) external view returns (bool);

    function discoverService(string _key) external view returns (Service);
    function discoverService(string _key, bytes32 _interfaceHash) external view returns (Service);

}
