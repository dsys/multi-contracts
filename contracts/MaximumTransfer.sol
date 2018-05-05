pragma solidity ^0.4.23;

import "./Service.sol";

contract MaximumTransfer is Service {

    function maximumFrom(address _token, address _from) external view returns (uint256);

    function maximumTo(address _token, address _to) external view returns (uint256);

}
