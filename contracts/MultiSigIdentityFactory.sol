pragma solidity ^0.4.23;

import "./MultiSigIdentity.sol";

contract MultiSigIdentityFactory {

    event IdentityCreated(MultiSigIdentity _identity, address _owner, uint _createdAt);

    function create(address _owner) external returns (MultiSigIdentity) {
        MultiSigIdentity identity = new MultiSigIdentity(_owner);
        emit IdentityCreated(identity, _owner, block.timestamp); // solium-disable-line security/no-block-members
        return identity;
    }

}
