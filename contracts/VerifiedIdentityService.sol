/* solium-disable operator-whitespace */

pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./IdentityService.sol";

contract VerifiedIdentityService is IdentityService, Ownable {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.VerifiedIdentityService");

    event ServiceSet(string indexed _serviceType, Service _svc, uint _updatedAt);
    event ServiceDeleted(string indexed _serviceType, uint _deletedAt);

    mapping(address => bytes32) awaitingVerification;
    mapping(address => bool) registered;
    mapping(string => Service) services;

    function name() external view returns (string) {
        return "VerifiedIdentityService";
    }

    function supportsInterface(bytes32 _interfaceHash) external view returns (bool) {
        return
            _interfaceHash == Service.InterfaceHash ||
            // _interfaceHash == ServiceRegistry.InterfaceHash ||
            _interfaceHash == IdentityService.InterfaceHash ||
            _interfaceHash == VerifiedIdentityService.InterfaceHash;
    }

    function serviceMetadata() external view returns (string) {
        return "https://portal.cleargraph.com/ethereum";
    }

    function register(bytes32 _data) external returns (uint256) {
        awaitingVerification[msg.sender] = _data;
        return 1;
    }

    function verify(address _subject, bytes32 _data) onlyOwner external {
        require(awaitingVerification[_subject] == _data);
        registered[_subject] = true;
        emit IdentityRegistered(_subject, _data, block.timestamp); // solium-disable-line security/no-block-members
    }

    function deregister() external returns (uint256) {
        registered[msg.sender] = false;
        emit IdentityDeregistered(msg.sender, block.timestamp); // solium-disable-line security/no-block-members
        return 0;
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

    function isRegisteredSelf() external view returns (bool) {
        return registered[msg.sender];
    }

    function setService(string _serviceType, Service svc) onlyOwner external {
        services[_serviceType] = svc;
        emit ServiceSet(_serviceType, svc, block.timestamp); // solium-disable-line security/no-block-members
    }

    function deleteService(string _serviceType) onlyOwner external {
        delete services[_serviceType];
        emit ServiceDeleted(_serviceType, block.timestamp); // solium-disable-line security/no-block-members
    }

    function discover(string _serviceType) external view returns (Service) {
        return services[_serviceType];
    }

}
