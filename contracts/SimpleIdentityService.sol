pragma solidity ^0.4.23;

import "./IdentityService.sol";
import "./Ownable.sol";
import "./ServiceRegistry.sol";

contract SimpleIdentityService is IdentityService, Ownable {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.SimpleIdentityService");

    ServiceRegistry public registry;
    mapping(address => bool) private registered;

    constructor(ServiceRegistry _registry) public {
        registry = _registry;
    }

    function name() external view returns (string) {
        return "SimpleIdentityService";
    }

    function serviceMetadata() external view returns (string) {
        return "example.com";
    }

    function supportsInterface(bytes32 _interfaceHash) external view returns (bool) {
        return
            _interfaceHash == Service.InterfaceHash ||
            // _interfaceHash == ServiceRegistry.InterfaceHash ||
            _interfaceHash == IdentityService.InterfaceHash ||
            _interfaceHash == SimpleIdentityService.InterfaceHash;
    }

    function register(bytes32 _data) external returns (uint256) {
        registered[msg.sender] = true;
        emit IdentityRegistered(msg.sender, _data, block.timestamp); // solium-disable-line security/no-block-members
        return 0;
    }

    function deregister() external returns (uint256) {
        registered[msg.sender] = false;
        emit IdentityDeregistered(msg.sender, block.timestamp); // solium-disable-line security/no-block-members
        return 0;
    }

    function isRegistered() external view returns (bool) {
        return registered[msg.sender];
    }

    function isRegistered(address _subject) external view returns (bool) {
        return registered[_subject];
    }

    function isRegistered(address[] _subjects) external view returns (bool) {
        for (uint i = 0; i < _subjects.length; i++) {
            if (!registered[_subjects[i]]) {
                return false;
            }
        }

        return true;
    }

    function supportsService(string _key) external view returns (bool) {
        return registry.supportsService(_key);
    }

    function supportsService(string _key, bytes32 _interfaceHash) external view returns (bool) {
        return registry.supportsService(_key, _interfaceHash);
    }

    function discoverService(string _key) external view returns (Service) {
        return registry.discoverService(_key);
    }

    function discoverService(string _key, bytes32 _interfaceHash) external view returns (Service) {
        return registry.discoverService(_key, _interfaceHash);
    }

}
