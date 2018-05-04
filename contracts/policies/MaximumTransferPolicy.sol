contract MaximumTransferPolicy is IdentityProviderPolicy {

  string registry;

  function MaximumTransferPolicy(IdentityProvider _provider) {
    MaximumTransferPolicy(_provider, "token.max");
  }

  function MaximumTransferPolicy(IdentityProvider _provider, string _registry) {
    super(_provider);
    registry = _registry;
  }

  function setRegistry(string _registry) onlyOwner external {
    registry = _registry;
  }

  function check(
    address _token,
    address _subject
  ) external returns (byte result) {
    return 0;
  }

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) public returns (byte result) {
    // TODO: Cruft, should be in a library of some kind.
    IntegerValueIdentityRegistry registry = IntegerValueIdentityRegistry(provider.discover(registry, IntegerValueIdentityRegistry.getValue.selector));
    if (amount > registry.getValue(_from)) {
      return 1;
    } else if (amount > registry.getValue(_to)) {
      return 2;
    } else {
      return 0;
    }
  }

}
