pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./Service.sol";

contract ServiceRegistry is Ownable, Service {

    bytes32 constant InterfaceHash = keccak256("com.cleargraph.ServiceRegistry");

    event ServiceSet(string _key, Service _svc, uint _updatedAt);
    event ServiceDeleted(string _key, uint _deletedAt);

    mapping(string => Service) services;

    function name() external view returns (string) {
        return "ServiceRegistry";
    }

    function serviceMetadata() external view returns (string) {
        return "https://cleargraph.com/docs#ServiceRegistry";
    }

    function supportsInterface(bytes32 _interfaceHash) external view returns (bool) {
        return
            _interfaceHash == Service.InterfaceHash ||
            _interfaceHash == ServiceRegistry.InterfaceHash;
    }

    function supportsService(string _key) external view returns (bool) {
        return address(services[_key]) != 0;
    }

    function supportsService(string _key, bytes32 _interfaceHash) external view returns (bool) {
        Service svc = services[_key];
        return address(svc) != 0 && svc.supportsInterface(_interfaceHash);
    }

    function discoverService(string _key) external view returns (Service) {
        return services[_key];
    }

    function discoverService(string _key, bytes32 _interfaceHash) external view returns (Service) {
        Service svc = services[_key];
        return address(svc) != 0 && svc.supportsInterface(_interfaceHash) ? svc : Service(0);
    }

    function setService(string _key, Service _svc) onlyOwner external {
        services[_key] = _svc;
        emit ServiceSet(_key, _svc, block.timestamp); // solium-disable-line security/no-block-members
    }

    function deleteService(string _key) onlyOwner external {
        delete services[_key];
        emit ServiceDeleted(_key, block.timestamp); // solium-disable-line security/no-block-members

    }

}
