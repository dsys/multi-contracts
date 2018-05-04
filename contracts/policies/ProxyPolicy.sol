pragma solidity ^0.4.23;

import "../Ownable.sol";
import "./ERC902.sol";

contract ProxyPolicy is Ownable, ERC902 {

  ERC902 delegate;

  constructor(ERC902 _delegate) public {
    delegate = _delegate;
  }

  function setDelegate(ERC902 _delegate) onlyOwner external {
    delegate = _delegate;
  }

  function check(
    address _token,
    address _subject
  ) external view returns (byte result) {
    return delegate.check(_token, _subject);
  }

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) external view returns (byte result) {
    return delegate.check(_token, _from, _to, _amount);
  }

}
