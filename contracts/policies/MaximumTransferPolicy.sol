pragma solidity ^0.4.23;

import './IdentityProviderPolicy.sol';
import '../registries/IntegerValueIdentityRegistry.sol';

contract MaximumTransferPolicy is IdentityProviderPolicy {

  string registryId;

  constructor(IdentityProvider _provider) public {
    IdentityProviderPolicy(_provider);
    registryId = "token.max";
  }

  function setRegistryId(string _registryId) onlyOwner external {
    registryId = _registryId;
  }

  function check(
    address,
    address
  ) external view returns (byte result) {
    return 0;
  }

  function check(
    address,
    address _from,
    address _to,
    uint256 _amount
  ) external view returns (byte result) {
    // TODO: Cruft, should be in a library of some kind.
    IntegerValueIdentityRegistry registry = IntegerValueIdentityRegistry(provider.discover(registryId));
    if (_amount > registry.getValue(_from)) {
      return 1;
    } else if (_amount > registry.getValue(_to)) {
      return 2;
    } else {
      return 0;
    }
  }

}
