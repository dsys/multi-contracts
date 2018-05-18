pragma solidity ^0.4.23;

/**
 * @title Service
 * @dev The Service interface is a generic interface for service providers.
 */
contract Service {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.Service");

    /**
     * @dev Returns the name of the service.
     */
    function name() external view returns (string);

    /**
     * @dev Returns metadata about the servicer in the form of a multiaddress.
     */
    function serviceMetadata() external view returns (string);

    /**
     * @dev Returns whether or not a service interface is supported.
     */
    function supportsInterface(bytes32 _interfaceHash) external view returns (bool);

}
