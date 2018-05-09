pragma solidity ^0.4.23;

import "../MaximumTransfer.sol";
import "./IdentityProviderPolicy.sol";

contract MaximumTransferPolicy is IdentityProviderPolicy {

    function check(
        address,
        address
    ) external view returns (byte) {
        return byte(0);
    }

    function check(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (byte) {
        Service svc = provider.discover("com.cleargraph.MaximumTransfer");
        if (svc == address(0)) return byte(1);

        MaximumTransfer transfer = MaximumTransfer(svc);
        if (_amount > transfer.maximumFrom(_token, _from)) return byte(2);
        if (_amount > transfer.maximumTo(_token, _to)) return byte(3);
        return byte(0);
    }

}
