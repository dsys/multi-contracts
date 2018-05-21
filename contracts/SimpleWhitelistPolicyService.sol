/* solium-disable operator-whitespace */

pragma solidity ^0.4.23;

import "./IdentityService.sol";
import "./Ownable.sol";
import "./PolicyService.sol";

contract SimpleWhitelistPolicyService is PolicyService, Ownable {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.SimpleWhitelistPolicyService");

    IdentityService identityService;

    constructor(IdentityService _identityService) public {
        identityService = _identityService;
    }

    function name() external view returns (string) {
        return "SimpleWhitelistPolicyService";
    }

    function serviceMetadata() external view returns (string) {
        return "https://cleargraph.com/docs#SimpleWhitelistPolicyService";
    }

    function supportsInterface(bytes32 _interfaceHash) external view returns (bool) {
        return
            _interfaceHash == Service.InterfaceHash ||
            // _interfaceHash == ServiceDiscovery.InterfaceHash ||
            _interfaceHash == PolicyService.InterfaceHash ||
            _interfaceHash == SimpleWhitelistPolicyService.InterfaceHash;
    }

    function setIdentityService(IdentityService _identityService) onlyOwner external {
        identityService = _identityService;
    }

    function check(
        address,
        address _subject
    ) external view returns (byte) {
        return identityService.isRegistered(_subject) ? byte(0) : byte(1);
    }

    function check(
        address,
        address _from,
        address _to,
        uint256
    ) external view returns (byte) {
        address[] memory subjects = new address[](2);
        subjects[0] = _from;
        subjects[1] = _to;
        return identityService.isRegistered(subjects) ? byte(0) : byte(1);
    }

    function supportsService(string _key) external view returns (bool) {
        return identityService.supportsService(_key);
    }

    function supportsService(string _key, bytes32 _interfaceHash) external view returns (bool) {
        return identityService.supportsService(_key, _interfaceHash);
    }

    function discoverService(string _key) external view returns (Service) {
        return identityService.discoverService(_key);
    }

    function discoverService(string _key, bytes32 _interfaceHash) external view returns (Service) {
        return identityService.discoverService(_key, _interfaceHash);
    }

}
