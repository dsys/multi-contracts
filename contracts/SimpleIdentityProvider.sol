pragma solidity ^0.4.23;

import "./IdentityProvider.sol";

contract SimpleIdentityProvider is IdentityProvider {

    mapping(address => bool) registered;

    function name() external view returns (string) {
        return "SimpleIdentityProvider";
    }

    function serviceType() external view returns (string) {
        return "com.cleargraph.IdentityProvider";
    }

    function serviceMetadata() external view returns (string) {
        return "example.com";
    }

    function register(bytes32 _data) external returns (uint256) {
        registered[msg.sender] = true;
        emit IdentityRegistered(msg.sender, _data, now);
        return 0;
    }

    function unregister() external returns (uint256) {
        registered[msg.sender] = false;
        emit IdentityUnregistered(msg.sender, now);
        return 0;
    }

    function isRegistered(address _subject) external view returns (bool) {
        return registered[_subject];
    }

    function isRegisteredMany(address[] _subjects) external view returns (bool) {
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

    function discover(string) external view returns (Service) {
        return Service(0);
    }

}
