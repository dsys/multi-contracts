pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ECRecovery.sol";

contract MultiSigIdentity {

  event OwnerAdded(address _owner, uint _addedAt);
  event OwnerRemoved(address _owner, uint _addedAt);

  event SignerAdded(address _signer, uint _addedAt);
  event SignerRemoved(address _signer, uint _addedAt);

  mapping(address => bool) ownersMapping;
  address[] public owners;

  mapping(address => bool) signersMapping;
  address[] public signers;

  uint256 public nonce;

  modifier onlyOwner() {
    require(isOwner(msg.sender));
    _;
  }

  constructor(address _owner) public {
    _addOwner(_owner);
  }

  // Owner management
  // ===========================================================================

  function getOwners() external view returns (address[]) {
    return owners;
  }

  function isOwner(address _address) public view returns (bool) {
    return ownersMapping[_address];
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
    ownersMapping[_address] = true;
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
    if (!isOwner(_address)) return;
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
        delete ownersMapping[_address];

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
    return signersMapping[_address];
  }

  function isSignerSignature(bytes32 message, bytes sig) public view returns (bool) {
    bytes32 hash = ECRecovery.toEthSignedMessageHash(message);
    return isSigner(ECRecovery.recover(hash, sig));
  }

  function addSigner(address _address) onlyOwner external {
    _addSigner(_address);
  }

  function addSignerSigned(address _address, bytes sig) external {
    bytes32 message = getAddOwnerSignedMessage(_address);
    require(isOwnerSignature(message, sig));
    _addSigner(_address);
  }

  function getAddSignerSignedMessage(address _address) public view returns (bytes32) {
    return keccak256(byte(0x19), byte(0), this, nonce, "addSigner", _address);
  }

  function _addSigner(address _address) internal {
    if (isOwner(_address) || isSigner(_address)) return;
    signersMapping[_address] = true;
    signers.push(_address);
    emit SignerAdded(_address, block.timestamp);
  }

  function removeSigner(address _address) onlyOwner external {
    _removeSigner(_address);
  }

  function removeSignerSigned(address _address, bytes sig) external {
    bytes32 message = getRemoveSignerSignedMessage(_address);
    require(isOwnerSignature(message, sig));
    _removeSigner(_address);
  }

  function getRemoveSignerSignedMessage(address _address) public view returns (bytes32) {
    return keccak256(byte(0x19), byte(0), this, nonce, "removeSigner", _address);
  }

  function _removeSigner(address _address) internal {
    if (isOwner(_address) || !isSigner(_address)) return;
    for (uint8 i = 0; i < signers.length; i++) {
      if (_address == signers[i]) {
        // replace the hole with the last element
        if (i != i - 1) {
          signers[i] = signers[signers.length - 1];
        }
        delete signers[signers.length - 1];
        signers.length--;
        delete signersMapping[_address];

        emit SignerRemoved(_address, block.timestamp);
        return;
      }
    }
  }

}
