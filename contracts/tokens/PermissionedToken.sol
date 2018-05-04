contract PermissionedToken {

  ERC902 validator;

  modifier check() {
    require(validator.check(this, msg.sender) == 0);
    _;
  }

  modifier check(address _subject) {
    require(validator.check(this, _subject) == 0);
    _;
  }

  modifier check(address _from, address _to, uint256 _amount) {
    require(validator.check(this, _from, _to, _amount) == 0);
    _;
  }

}
