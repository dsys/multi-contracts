pragma solidity ^0.4.23;

interface ERC902 {
  function check(
    address _token,
    address _subject
  ) external view returns (byte result);

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) external view returns (byte result);
}
