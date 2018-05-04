pragma solidity ^0.4.23;

import '../Ownable.sol';
import '../ERC165.sol';

contract IdentityRegistry is Ownable, ERC165 {

  /**
   * @dev Returns if the _subject address is present in the identity registry.
   */
  function isPresent(address _subject) external view returns (bool);

}
