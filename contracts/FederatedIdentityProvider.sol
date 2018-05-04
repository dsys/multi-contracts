import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title IdentityProvider
 * @dev The IdentityProvider contract allows addresses to register or deregister with an off-chain identity provider.
 */
interface IdentityProvider {

  event IdentityRegistered(address addr);
  event IdentityDeregistered(address addr);

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

}
