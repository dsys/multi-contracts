contract SimpleWhitelistPolicy is IdentityProviderPolicy {

  string registry;

  function IdentityProviderPolicy(IdentityProvider _provider) {
    IdentityProviderPolicy(_provider, "token.whitelist");
  }

  function IdentityProviderPolicy(IdentityProvider _provider, string _registry) {
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
    IdentityRegistry registry = provider.discover(registry)
    if (registry.isPresent(_subject)) {
      return 0;
    } else {
      return 1;
    }
  }

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) public returns (byte result) {
    IdentityRegistry registry = provider.discover(registry)
    if (!registry.isPresent(_from)) {
      return 1;
    } else if (!registry.isPresent(_to)) {
      return 2;
    } else {
      return 0;
    }
  }

}
