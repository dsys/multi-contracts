pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ECRecovery.sol";

contract MultiSigIdentity {

  event OwnerAdded(address _owner, uint _addedAt);
  event OwnerRemoved(address _owner, uint _addedAt);

  event SignerAdded(address _signer, uint _addedAt);
  event SignerRemoved(address _signer, uint _addedAt);

  address[] public owners;
  address[] public signers;
  uint256 public nonce;

  modifier onlyOwner() {
    require(isOwner(msg.sender));
    _;
  }

  constructor(address _owner) public {
    owners.push(_owner);
    signers.push(_owner);
  }

  // Owner management
  // ===========================================================================

  function getOwners() external view returns (address[]) {
    return owners;
  }

  function isOwner(address _address) public view returns (bool) {
    for (uint8 i = 0; i < owners.length; i++) {
      if (_address == owners[i]) {
        return true;
      }
    }
    return false;
  }

  function isOwnerSignature(bytes32 message, bytes sig) public view returns (bool) {
    bytes32 hash = ECRecovery.toEthSignedMessageHash(message);
    return isOwner(ECRecovery.recover(hash, sig));
  }

  function addOwner(address _address) onlyOwner external {
    _addOwner(_address);
  }

  function addOwnerSigned(address _address, bytes sig) external {
    bytes32 message = getAddOwnerSignedMessage(_address);
    require(isOwnerSignature(message, sig));
    _addOwner(_address);
  }

  function getAddOwnerSignedMessage(address _address) public view returns (bytes32) {
    return keccak256(byte(0x19), byte(0), this, nonce, "addOwner", _address);
  }

  function _addOwner(address _address) internal {
    if (isOwner(_address)) return;
    owners.push(_address);
    emit OwnerAdded(_address, block.timestamp);
  }

  function removeOwner(address _address) onlyOwner external {
    _removeOwner(_address);
  }

  function removeOwnerSigned(address _address, bytes sig) external {
    bytes32 message = getRemoveOwnerSignedMessage(_address);
    require(isOwnerSignature(message, sig));
    _removeOwner(_address);
  }

  function getRemoveOwnerSignedMessage(address _address) public view returns (bytes32) {
    return keccak256(byte(0x19), byte(0), this, nonce, "removeOwner", _address);
  }

  function _removeOwner(address _address) internal {
    for (uint8 i = 0; i < owners.length; i++) {
      if (_address == owners[i]) {
        // don't allow removal of the last owner
        require(owners.length > 1);

        // replace the hole with the last element
        if (i != i - 1) {
          owners[i] = owners[owners.length - 1];
        }
        delete owners[owners.length - 1];
        owners.length--;

        emit OwnerRemoved(_address, block.timestamp);
        return;
      }
    }
  }

  // Signer management
  // ===========================================================================

  function getSigners() external view returns (address[]) {
    return signers;
  }

  function isSigner(address _address) public view returns (bool) {
    for (uint8 i = 0; i < signers.length; i++) {
      if (_address == signers[i]) {
        return true;
      }
    }
    return false;
  }

  function isSignerSignature(bytes32 message, bytes sig) public view returns (bool) {
    bytes32 hash = ECRecovery.toEthSignedMessageHash(message);
    return isSigner(ECRecovery.recover(hash, sig));
  }

  function addSigner(address _signer) onlyOwner external {
    emit SignerAdded(_signer, block.timestamp);
  }

  function addSignerSigned(address _signer, bytes sig) external {
    bytes32 message = keccak256(byte(0x19), byte(0), this, nonce, "addSigner", _signer);
    require(isOwnerSignature(message, sig));
    emit SignerAdded(_signer, block.timestamp);
  }

  function removeSigner(address _signer) onlyOwner external {
    emit SignerRemoved(_signer, block.timestamp);
  }

  function removeSignerSigned(address _signer, bytes sig) external {
    bytes32 message = keccak256(byte(0x19), byte(0), this, nonce, "removeSigner", _signer);
    require(isOwnerSignature(message, sig));
    emit SignerRemoved(_signer, block.timestamp);
  }

}
