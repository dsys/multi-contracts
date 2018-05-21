pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ECRecovery.sol";

contract MultiSigIdentity {

  uint8 constant SIGNATURE_LENGTH = 72;

  event Received(address indexed sender, uint value);

  event OwnerAdded(address _owner, uint _addedAt);
  event OwnerRemoved(address _owner, uint _removedAt);

  event SignerAdded(address _signer, uint _addedAt);
  event SignerRemoved(address _signer, uint _removedAt);

  event SignerThresholdChanged(uint8 _signerThreshold, uint _changedAt);
  event CallExecuted(address _to, uint256 _value, bytes _data, uint _executedAt);

  mapping(address => bool) ownersMapping;
  address[] public owners;

  mapping(address => bool) signersMapping;
  address[] public signers;

  uint8 signerThreshold;
  uint256 public nonce;

  modifier onlyOwner() {
    require(isOwner(msg.sender));
    _;
  }

  constructor(address _owner) public {
    _addOwner(_owner);
  }

  function () public payable { emit Received(msg.sender, msg.value); }

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

  // Threshold configuration
  // ===========================================================================

  function getSignerThreshold() external view returns (uint8) {
    return signerThreshold;
  }

  function setSignerThreshold(uint8 _signerThreshold) onlyOwner external {
    _setSignerThreshold(_signerThreshold);
  }

  function setSignerThresholdSigned(uint8 _signerThreshold, bytes sig) external {
    bytes32 message = getSetSignerThresholdSignedMessage(_signerThreshold);
    require(isOwnerSignature(message, sig));
    _setSignerThreshold(_signerThreshold);
  }

  function _setSignerThreshold(uint8 _signerThreshold) internal {
    signerThreshold = _signerThreshold;
    emit SignerThresholdChanged(_signerThreshold, block.timestamp);
  }

  function getSetSignerThresholdSignedMessage(uint8 _signerThreshold) public view returns (bytes32) {
    return keccak256(byte(0x19), byte(0), this, nonce, "setSignerThreshold", _signerThreshold);
  }

  function meetsSignerThreshold(bytes32 _message, bytes _sig) public view returns (bool) {
    if (_sig.length == 65) {
      return isOwnerSignature(_message, _sig);
    }

    require(_sig.length % SIGNATURE_LENGTH == 0);

    bytes32 hash = ECRecovery.toEthSignedMessageHash(_message);
    uint signatureCount = _sig.length / SIGNATURE_LENGTH;

    address[] memory signersReceived = new address[](signatureCount);
    uint8 uniqueCount;

    for (uint i = 0; i < signatureCount; i++) {
      address addr = recoverKey(hash, _sig, i);
      if (ownersMapping[addr]) {
        // if an owner signature is present, accept
        return true;
      } else if (signersMapping[addr]) {
        // only count unique signer signatures
        bool found = false;
        for (uint8 j = 0; j < uniqueCount; j++) {
          if (addr == signersReceived[j]) {
            found = true;
            break;
          }
        }
        if (!found) {
          signersReceived[uniqueCount] = addr;
          uniqueCount++;
        }
      }
    }

    return uniqueCount >= 1 && uniqueCount >= signerThreshold;
  }

  // Execute
  // ===========================================================================

  function executeCall(address _to, uint256 _value, bytes _data) external returns (bool) {
    require(isOwner(msg.sender) || (isSigner(msg.sender) && signerThreshold <= 1));
    return _executeCall(_to, _value, _data);
  }

  // TODO: Might be able to process the signatures as a single bytes array if they're a fixed length.
  function executeCallSigned(address _to, uint256 _value, bytes _data, bytes _sig) external returns (bool) {
    require(_to != address(this) && _to != address(0));
    bytes32 message = getExecuteCallSignedMessage(_to, _value, _data);
    require(meetsSignerThreshold(message, _sig));
    return _executeCall(_to, _value, _data);
  }

  function _executeCall(address _to, uint256 _value, bytes _data) internal returns (bool success) {
    require(_to != address(this) && _to != address(0));

    // increment nonce to prevent reentrancy
    nonce++;

    assembly {
      success := call(gas, _to, _value, add(_data, 0x20), mload(_data), 0, 0)
    }

    emit CallExecuted(_to, _value, _data, block.timestamp);
  }

  function getExecuteCallSignedMessage(address _to, uint256 _value, bytes _data) public view returns (bytes32) {
    return keccak256(byte(0x19), byte(0), this, nonce, "executeCall", _to, _value, _data);
  }

  // TODO: Extract signature utils into npm module.

  function recoverKey (
    bytes32 _hash, 
    bytes _sigs,
    uint256 _pos
  ) private pure returns (address) {
    uint8 v;
    bytes32 r;
    bytes32 s;
    (v, r, s) = signatureSplit(_sigs, _pos);
    return ecrecover(
      _hash,
      v,
      r,
      s
    );
  }

  function signatureSplit(
    bytes _signatures,
    uint256 _pos
  ) private pure returns (uint8 v, bytes32 r, bytes32 s) {
    uint256 offset = _pos * SIGNATURE_LENGTH;
    assembly {
      r := mload(add(_signatures, add(32, offset)))
      s := mload(add(_signatures, add(64, offset)))
      // Here we are loading the last 32 bytes, including 31 bytes
      // of 's'. There is no 'mload8' to do this.
      //
      // 'byte' is not working due to the Solidity parser, so lets
      // use the second best option, 'and'
      v := and(mload(add(_signatures, add(65, offset))), 0xff)
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    require(v == 27 || v == 28);
  }

}
