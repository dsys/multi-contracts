import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @name IdentityRegistry
 * @dev Loosely based on ERC 780, with support for only a single issuer (owner) per registry.
 */
function IdentityRegistry is Ownable, ERC165 {

  /**
    * @dev Returns if the _subject address is present in the identity registry.
    */
  function isPresent(address _subject) external view returns (bool);

}
