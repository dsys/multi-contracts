pragma solidity ^0.4.23;

import "./Service.sol";
import "./ServiceDiscovery.sol";

contract PolicyService is Service, ServiceDiscovery {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.PolicyService");

    function check(
        address _token,
        address _subject
    ) external view returns (
        byte result);

    function check(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (
        byte result);

}
