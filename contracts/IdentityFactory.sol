pragma solidity ^0.4.24;

import "./Identity.sol";

contract IdentityFactory {

    event IdentityCreated(Identity _identity, address _owner, uint _createdAt);

    function create(address _owner) external returns (Identity) {
        Identity identity = new Identity(_owner);
        emit IdentityCreated(identity, _owner, block.timestamp); // solium-disable-line security/no-block-members
        return identity;
    }

}
