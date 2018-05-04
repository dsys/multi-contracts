pragma solidity ^0.4.23;

import "./IdentityProviderPolicy.sol";

contract SimpleWhitelistPolicy is IdentityProviderPolicy {

  string registryType;

  constructor(IdentityProvider _provider) public {
    IdentityProviderPolicy(_provider);
    registryType = "token.whitelist";
  }

  function setRegistryType(string _registryType) onlyOwner external {
    registryType = _registryType;
  }

  function check(
    address,
    address _subject
  ) external view returns (byte result) {
    IdentityRegistry registry = provider.discover(registryType);
    if (registry.isPresent(_subject)) {
      return 0;
    } else {
      return 1;
    }
  }

  function check(
    address,
    address _from,
    address _to,
    uint256
  ) external view returns (byte result) {
    IdentityRegistry registry = provider.discover(registryType);
    if (!registry.isPresent(_from)) {
      return 1;
    } else if (!registry.isPresent(_to)) {
      return 2;
    } else {
      return 0;
    }
  }

}
