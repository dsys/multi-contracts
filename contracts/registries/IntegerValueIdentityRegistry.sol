import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

import './IdentityRegistry.sol'

contract IntegerValueIdentityRegistry is IdentityRegistry, Ownable {

  mapping(address => uint256) claims;

  event SetValue(
    address indexed subject,
    uint256 value,
    uint updatedAt);

  event RemoveValue(
    address indexed subject,
    bytes32 indexed key,
    uint removedAt);

  function getValue(address _subject) external view returns (uint256);
  function setValue(address _subject, uint256 _value) external;
  function removeValue(address _subject, uint256 _value) external;

  function isPresent(address _subject) external view returns (bool);

}
