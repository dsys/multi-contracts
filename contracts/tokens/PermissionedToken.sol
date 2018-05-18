pragma solidity ^0.4.23;

import "../PolicyService.sol";

contract PermissionedToken {

    PolicyService policy;

    modifier checkSender() {
        require(policy.check(this, msg.sender) == 0);
        _;
    }

    modifier checkSubject(address _subject) {
        require(policy.check(this, _subject) == 0);
        _;
    }

    modifier checkTransfer(address _from, address _to, uint256 _amount) {
        require(policy.check(this, _from, _to, _amount) == 0);
        _;
    }

}
