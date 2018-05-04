import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

import './IdentityRegistry.sol'

contract GenericIdentityRegistry is IdentityRegistry, Ownable {

  mapping(address => mapping(bytes32 => bytes32)) claims;

  event ClaimSet(
    address indexed subject,
    bytes32 indexed key,
    bytes32 value,
    uint updatedAt);

  event ClaimRemoved(
    address indexed subject,
    bytes32 indexed key,
    uint removedAt);

  function getClaim(address _subject, bytes32 _key) external view returns (bytes32);
  function setClaim(address _subject, bytes32 _key, bytes32 _value) onlyOwner external;
  function removeClaim(address _subject, bytes32 _key) onlyOwner external;

  function isPresent(address _subject) external view returns (boolj);

}
