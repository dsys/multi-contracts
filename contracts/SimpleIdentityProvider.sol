pragma solidity ^0.4.23;

import "./IdentityProvider.sol";

contract SimpleIdentityProvider is IdentityProvider {

    mapping(address => bool) registered;

    function register(bytes32) external returns (uint256) {
        registered[msg.sender] = true;
        emit IdentityRegistered(msg.sender);
        return 0;
    }

    function unregister() external returns (uint256) {
        registered[msg.sender] = false;
        emit IdentityUnregistered(msg.sender);
        return 0;
    }

    function isRegisteredSelf() external view returns (bool) {
        return registered[msg.sender];
    }

    function isRegistered(address _subject) external view returns (bool) {
        return registered[_subject];
    }

    function discover(string) external view returns (IdentityRegistry) {
        return IdentityRegistry(0);
    }

    function discover(string, bytes4) external view returns (IdentityRegistry) {
        return IdentityRegistry(0);
    }

}
