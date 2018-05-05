pragma solidity ^0.4.23;

import "./IdentityProviderPolicy.sol";

contract SimpleWhitelistPolicy is IdentityProviderPolicy {

    constructor(IdentityProvider _provider) IdentityProviderPolicy(_provider) public {
    }

    function check(
      address,
      address _subject
    ) external view returns (byte) {
      return provider.isRegistered(_subject) ? byte(0) : byte(1);
    }

    function check(
      address,
      address _from,
      address _to,
      uint256
    ) external view returns (byte) {
      address[] memory subjects = new address[](2);
      subjects[0] = _from;
      subjects[1] = _to;
      return provider.isRegisteredMany(subjects) ? byte(0) : byte(1);
    }

}
