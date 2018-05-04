interface ERC902 {
  function check(
    address _token,
    address _subject
  ) public returns (byte result);

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) public returns (byte result);
}
