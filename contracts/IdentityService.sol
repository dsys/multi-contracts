pragma solidity ^0.4.23;

import "./Service.sol";
import "./ServiceDiscovery.sol";

/**
 * @title IdentityService
 * @dev The IdentityService contract allows addresses to register or deregister with an off-chain identity provider.
 */
contract IdentityService is Service, ServiceDiscovery {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.IdentityService");

    event IdentityRegistered(address addr, bytes32 data, uint registeredAt);
    event IdentityDeregistered(address addr, uint deregisteredAt);

    /**
    * @dev Registers the message's sender with the IdentityService.
    * @dev The identity provider may use _data to connect the request to an off-chain user account.
    */
    function register(bytes32 _data) external returns (uint256);

    /**
    * @dev Deregisters the message's sender with the IdentityService.
    * @dev Other possible names: erase, delete, deregister, forget.
    */
    function deregister() external returns (uint256);

    /**
    * @dev Checks if the message sender is registered.
    */
    function isRegistered() external view returns (bool);

    /**
    * @dev Checks if a user is registered.
    */
    function isRegistered(address _subject) external view returns (bool);

    /**
    * @dev Checks if a list of users are registered.
    */
    function isRegistered(address[] _subjects) external view returns (bool);

}
