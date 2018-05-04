pragma solidity ^0.4.23;

import '../IdentityProvider.sol';
import '../Ownable.sol';
import './ERC902.sol';

contract IdentityProviderPolicy is Ownable, ERC902 {

  IdentityProvider provider;

  constructor(IdentityProvider _provider) public {
    provider = _provider;
  }

  function setIdentityProvider(IdentityProvider _provider) onlyOwner external {
    provider = _provider;
  }

}
