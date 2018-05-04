pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./registries/IdentityRegistry.sol";

/**
 * @title IdentityProvider
 * @dev The IdentityProvider contract allows addresses to register or deregister with an off-chain identity provider.
 */
interface IdentityProvider {

  event IdentityRegistered(address addr);
  event IdentityUnregistered(address addr);

  /**
    * @dev Registers the message's sender with the IdentityProvider.
    * @dev The identity provider may use _data to connect the request to an off-chain user account.
    */
  function register(bytes32 _data) external returns (uint256);

  /**
    * @dev Deregisters the message's sender with the IdentityProvider.
    * @dev Other possible names: erase, delete, deregister, forget.
    */
  function unregister() external returns (uint256);

  /**
   * @dev Checks if the message sender is registered.
   */
  function isRegisteredSelf() external view returns (bool);

  /**
   * @dev Checks if a user is registered/
   */
  function isRegistered(address _subject) external view returns (bool);

  /**
    * @dev Performs discovery of an identity registry.
    * @dev Enables federation of identity providers.
    */
  function discover(string _registryType) external view returns (IdentityRegistry);

  /**
    * @dev Performs discovery of an identity registry that satisfies an Ethereum interface.
    * @dev Enables federation of identity providers.
    */
  function discover(string _registryType, bytes4 _interfaceId) external view returns (IdentityRegistry);

}
