pragma solidity ^0.4.23;

import '../Ownable.sol';
import './IdentityRegistry.sol';

contract GenericIdentityRegistry is IdentityRegistry {

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

  function getClaim(address _subject, bytes32 _key) external view returns (bytes32) {
    return claims[_subject][_key];
  }

  function setClaim(address _subject, bytes32 _key, bytes32 _value) onlyOwner external {
    claims[_subject][_key] = _value;
    emit ClaimSet(_subject, _key, _value, now);
  }

  function removeClaim(address _subject, bytes32 _key) onlyOwner external {
    delete claims[_subject][_key];
    emit ClaimRemoved(_subject, _key, now);
  }

  function isPresent(address) external view returns (bool) {
    return true;
  }

}
