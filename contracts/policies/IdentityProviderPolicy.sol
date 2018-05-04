contract IdentityProviderPolicy is Ownable, ERC902 {

  IdentityProvider provider;

  function IdentityProviderPolicy(IdentityProvider _provider) {
    provider = _provider;
  }

  function setIdentityProvider(IdentityProvider _provider) onlyOwner external {
    provider = _provider;
  }

}
