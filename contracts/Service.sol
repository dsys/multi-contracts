pragma solidity ^0.4.23;

/**
 * @title Service
 * @dev The Service interface is a generic interface for service providers.
 */
interface Service {

    /**
     * @dev Returns the name of the service.
     */
    function name() external view returns (string);

    /**
     * @dev Returns whether or not a service interface is supported.
     */
    function supportsInterface(string _interfaceName) external pure returns (bool);

    /**
     * @dev Returns metadata about the servicer in the form of a multiaddress.
     */
    function serviceMetadata() external view returns (string);

}
