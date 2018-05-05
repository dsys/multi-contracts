pragma solidity ^0.4.23;

import "./Service.sol";

/**
 * @title ServiceDiscovery
 * @dev The ServiceDiscovery interface allows callers to discover new services.
 */
interface ServiceDiscovery {

  /**
   * @dev Performs service discovery.
   */
  function discover(string _serviceType) external view returns (Service svc);

}
