pragma solidity ^0.4.24;

import { KeyManagement } from "./KeyManagement.sol";

/// @title KeyManagement
/// @author Alex Kern <alex@distributedsystems.com>
contract Identity {

    uint256 public constant MANAGEMENT_KEY = 1;
    uint256 public constant ACTION_KEY = 2;
    uint256 public constant CLAIM_KEY = 3;
    uint256 public constant ENCRYPTION_KEY = 4;

    uint256 public constant ECDSA = 1;
    uint256 public constant RSA = 2;

    uint256 public constant OPERATION_CALL = 0;
    uint256 public constant OPERATION_DELEGATECALL = 1;
    uint256 public constant OPERATION_CREATE = 2;

    using KeyManagement for KeyManagement.KeyManager;

    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event ExecutedSigned(bytes32 signHash, uint256 nonce, bool success);
    event Received(address indexed sender, uint256 value);

    /// @dev The struct that holds the identity's keys
    KeyManagement.KeyManager internal manager;

    /// @dev The last used nonce
    uint256 internal nonce;

    /// @dev Creates a new identity
    /// @param _owner The initial owner/management address of the newly created contract
    constructor(address _owner) public {
        manager.addKey(bytes32(_owner), MANAGEMENT_KEY, ECDSA);
    }

    /// @dev Default function making the identity contract payable
    function () public payable { emit Received(msg.sender, msg.value); }

    /// @dev Returns a key by the key's identifier
    /// @param _key The key to retrieve
    function getKey(
        bytes32 _key
    ) public view returns (uint256[], uint256, bytes32) {
        return manager.getKey(_key);
    }

    /// @dev Returns all keys on the identity with a purpose
    /// @param _purpose The purpose to check
    function getKeysByPurpose(
        uint256 _purpose
    ) public view returns (bytes32[]) {
        return manager.getKeysByPurpose(_purpose);
    }

    /// @dev Returns whether a key has a purpose
    /// @param _key The key to check
    /// @param _purpose The purpose to check
    function keyHasPurpose(
        bytes32 _key,
        uint256 _purpose
    ) public view returns (bool) {
        return manager.keyHasPurpose(_key, _purpose);
    }

    /// @dev Reverts if the caller is not a management address
    modifier onlyManagement {
        require(
            isManagementAddress(msg.sender),
            "Management address required"
        );
        _;
    }

    /// @dev Returns whether or not a subject is able to perform key management actions on behalf of the identity
    /// @param _subject The subject to check
    function isManagementAddress(
        address _subject
    ) public view returns (bool) {
        return _subject == address(this) || manager.keyHasPurpose(bytes32(_subject), MANAGEMENT_KEY);
    }

    /// @dev Returns whether or not a subject is able to perform actions on other contracts on behalf of the identity
    /// @param _subject The subject to check
    function isActionAddress(
        address _subject
    ) public view returns (bool) {
        return (
            _subject == address(this) ||
            manager.keyHasPurpose(bytes32(_subject), ACTION_KEY) ||
            manager.keyHasPurpose(bytes32(_subject), MANAGEMENT_KEY)
        );
    }

    /// @dev Adds a key to the identity contract
    /// @param _key The key to add
    /// @param _purpose The purpose of the key to add
    /// @param _keyType The key type of the key to add
    /// @return success Whether or not the key was added
    function addKey(
        bytes32 _key,
        uint256 _purpose,
        uint256 _keyType
    ) onlyManagement public returns (
        bool success
    ) {
        success = manager.addKey(_key, _purpose, _keyType);
        if (success) emit KeyAdded(_key, _purpose, _keyType);
    }

    /// @dev Removes a key from the identity contract
    /// @param _key The key to remove
    /// @param _purpose The purpose of the key to remove
    /// @return success Whether or not the key was removed
    function removeKey(
        bytes32 _key,
        uint256 _purpose
    ) onlyManagement public returns (
        bool success
    ) {
        require(
            _purpose != MANAGEMENT_KEY || manager.getKeysByPurpose(_purpose).length > 1,
            'Last management key cannot remove itself'
        );

        uint256 keyType;
        (, keyType, ) = manager.getKey(_key);
        success = manager.removeKey(_key, _purpose);
        if (success) emit KeyRemoved(_key, _purpose, keyType);
    }

    /// @dev Returns the last used nonce by the identity
    function lastNonce() public view returns (uint256) {
        return nonce;
    }

    /// @dev Verifies that the message hash and signatures are valid
    /// @param _messageHash The message hash to verify
    /// @param _messageHash The message signatures to verify
    function verifyMessageHash(
        bytes32 _messageHash,
        bytes _messageSignatures
    ) public {
        require(true == true); // TODO
    }

    /// @dev Returns the message hash that must be signed to execute a transaction
    /// @param _to The contract to the send the transaction to
    /// @param _from The contract to the send the transaction from
    /// @param _value The amount of ether to send in the transaction
    /// @param _data The transaction data
    /// @param _nonce The new nonce for the transaction
    /// @param _gasPrice The gas price paid in the gas token
    /// @param _gasLimit The maximum gas paid in the transaction
    /// @param _gasToken The token used to pay for the transaction, or 0 for ether
    /// @param _operationType The type of operation to use: 0 for call, 1 for delegatecall, 2 for create
    /// @param _extraHash The extra data to hash as part of the transaction, used for forward-compatibility
    function getMessageHash(
        address _to,
        address _from,
        uint256 _value,
        bytes _data,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _gasToken,
        uint256 _operationType,
        bytes _extraHash
    ) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                byte(0x19),
                byte(0),
                _from,
                _to,
                _value,
                keccak256(_data),
                _nonce,
                _gasPrice,
                _gasLimit,
                _gasToken,
                // _callPrefix, // FIXME: This is in ERC 1077 but isn't well-defined?
                _operationType,
                _extraHash
            )
        );
    }

    /// @dev Executes a signed transaction on behalf of the identity
    /// @param _to The contract to the send the transaction to
    /// @param _from The contract to the send the transaction from
    /// @param _value The amount of ether to send in the transaction
    /// @param _data The transaction data
    /// @param _nonce The new nonce for the transaction
    /// @param _gasPrice The gas price paid in the gas token
    /// @param _gasLimit The maximum gas paid in the transaction
    /// @param _gasToken The token used to pay for the transaction, or 0 for ether
    /// @param _operationType The type of operation to use: 0 for call, 1 for delegatecall, 2 for create
    /// @param _extraHash The extra data to hash as part of the transaction, used for forward-compatibility
    /// @param _messageSignatures The message signatures that authorize the transaction
    function executeSigned(
        address _to,
        address _from,
        uint256 _value,
        bytes _data,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _gasToken,
        uint256 _operationType,
        bytes _extraHash,
        bytes _messageSignatures
    ) public returns (bool success) {
        bytes32 messageHash = getMessageHash(
            _to,
            _from,
            _value,
            _data,
            _nonce,
            _gasPrice,
            _gasLimit,
            _gasToken,
            _operationType,
            _extraHash
        );

        verifyMessageHash(
            messageHash,
            _messageSignatures
        );

        nonce++; // increment nonce to prevent reentrancy

        _executeCall(_to, _value, _data);

        // TODO: Implement ERC 1077.
    }

    function _executeCall(
        address _to,
        uint256 _value,
        bytes _data
    ) internal returns (bool success) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := call(gas, _to, _value, add(_data, 0x20), mload(_data), 0, 0)
        }
    }

    /// @dev Estimates the amount of gas used by the transaction
    /// @param _to The contract to the send the transaction to
    /// @param _from The contract to the send the transaction from
    /// @param _value The amount of ether to send in the transaction
    /// @param _data The transaction data
    /// @param _nonce The new nonce for the transaction
    /// @param _gasPrice The gas price paid in the gas token
    /// @param _gasLimit The maximum gas paid in the transaction
    /// @param _gasToken The token used to pay for the transaction, or 0 for ether
    /// @param _operationType The type of operation to use: 0 for call, 1 for delegatecall, 2 for create
    /// @param _extraHash The extra data to hash as part of the transaction, used for forward-compatibility
    /// @param _messageSignatures The message signatures that authorize the transaction
    /// @return canExecute Whether or not the transaction would succeed
    /// @return gasCost The amount of gas that would be used by the transaction
    function gasEstimate(
        address _to,
        address _from,
        uint256 _value,
        bytes _data,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _gasToken,
        uint256 _operationType,
        bytes _extraHash,
        bytes _messageSignatures
    ) public view returns (
        bool canExecute,
        uint256 gasCost
    ) {
        // TODO: Implement ERC 1077.
    }

    // function execute(address _to, uint256 _value, bytes _data) external returns (bool) {
    //     if ((_to == address(this) && !isManagementAddress) && !isActionAddress(msg.sender)) return false;
    //     return _executeCall(_to, _value, _data);
    // }

    // function executeCallSigned(address _to, uint256 _value, bytes _data, bytes _sig) external returns (bool) {
    //     require(_to != address(this) && _to != address(0));
    //     bytes32 message = getExecuteCallSignedMessage(_to, _value, _data);
    //     require(meetsSignerThreshold(message, _sig));
    //     return _executeCall(_to, _value, _data);
    // }

    // function _executeCall(address _to, uint256 _value, bytes _data) internal returns (bool success) {
    //     require(_to != address(this) && _to != address(0));

    //     // increment nonce to prevent reentrancy
    //     nonce++;

    //     // solium-disable-next-line security/no-inline-assembly
    //     assembly {
    //         success := call(gas, _to, _value, add(_data, 0x20), mload(_data), 0, 0)
    //     }

    //     emit CallExecuted(_to, _value, _data, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // Signer management
    // ===========================================================================

    // function isSignerSignature(bytes32 message, bytes sig) public view returns (bool) {
    //     bytes32 hash = ECRecovery.toEthSignedMessageHash(message);
    //     return isSigner(ECRecovery.recover(hash, sig));
    // }

    // function addSigner(address _address) onlyOwner external {
    //     _addSigner(_address);
    // }

    // function addSignerSigned(address _address, bytes sig) external {
    //     bytes32 message = getAddOwnerSignedMessage(_address);
    //     require(isOwnerSignature(message, sig));
    //     _addSigner(_address);
    // }

    // function getAddSignerSignedMessage(address _address) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "addSigner", _address);
    // }

    // function _addSigner(address _address) internal {
    //     if (isOwner(_address) || isSigner(_address)) return;
    //     signersMapping[_address] = true;
    //     signers.push(_address);
    //     emit SignerAdded(_address, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // function removeSigner(address _address) onlyOwner external {
    //     _removeSigner(_address);
    // }

    // function removeSignerSigned(address _address, bytes sig) external {
    //     bytes32 message = getRemoveSignerSignedMessage(_address);
    //     require(isOwnerSignature(message, sig));
    //     _removeSigner(_address);
    // }

    // function getRemoveSignerSignedMessage(address _address) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "removeSigner", _address);
    // }

    // function _removeSigner(address _address) internal {
    //     if (isOwner(_address) || !isSigner(_address)) return;
    //     for (uint8 i = 0; i < signers.length; i++) {
    //         if (_address == signers[i]) {
    //             // replace the hole with the last element
    //             if (i != i - 1) {
    //                 signers[i] = signers[signers.length - 1];
    //             }
    //             delete signers[signers.length - 1];
    //             signers.length--;
    //             delete signersMapping[_address];

    //             emit SignerRemoved(_address, block.timestamp); // solium-disable-line security/no-block-members
    //             return;
    //         }
    //     }
    // }

    // // Threshold configuration
    // // ===========================================================================

    // function getSignerThreshold() external view returns (uint8) {
    //     return signerThreshold;
    // }

    // function setSignerThreshold(uint8 _signerThreshold) onlyOwner external {
    //     _setSignerThreshold(_signerThreshold);
    // }

    // function setSignerThresholdSigned(uint8 _signerThreshold, bytes sig) external {
    //     bytes32 message = getSetSignerThresholdSignedMessage(_signerThreshold);
    //     require(isOwnerSignature(message, sig));
    //     _setSignerThreshold(_signerThreshold);
    // }

    // function _setSignerThreshold(uint8 _signerThreshold) internal {
    //     signerThreshold = _signerThreshold;
    //     emit SignerThresholdChanged(_signerThreshold, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // function getSetSignerThresholdSignedMessage(uint8 _signerThreshold) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "setSignerThreshold", _signerThreshold);
    // }

    // function meetsSignerThreshold(bytes32 _message, bytes _sig) public view returns (bool) {
    //     if (_sig.length == 65) {
    //         return isOwnerSignature(_message, _sig);
    //     }

    //     require(_sig.length % SIGNATURE_LENGTH == 0);

    //     bytes32 hash = ECRecovery.toEthSignedMessageHash(_message);
    //     uint signatureCount = _sig.length / SIGNATURE_LENGTH;

    //     address[] memory signersReceived = new address[](signatureCount);
    //     uint8 uniqueCount;

    //     for (uint i = 0; i < signatureCount; i++) {
    //         address addr = recoverKey(hash, _sig, i);
    //         if (ownersMapping[addr]) {
    //             // if an owner signature is present, accept
    //             return true;
    //         } else if (signersMapping[addr]) {
    //             // only count unique signer signatures
    //             bool found = false;
    //             for (uint8 j = 0; j < uniqueCount; j++) {
    //                 if (addr == signersReceived[j]) {
    //                     found = true;
    //                     break;
    //                 }
    //             }
    //             if (!found) {
    //                 signersReceived[uniqueCount] = addr;
    //                 uniqueCount++;
    //             }
    //         }
    //     }

    //     return uniqueCount >= 1 && uniqueCount >= signerThreshold;
    // }

    // // Execute
    // // ===========================================================================

    // function executeCall(address _to, uint256 _value, bytes _data) external returns (bool) {
    //     require(isOwner(msg.sender) || (isSigner(msg.sender) && signerThreshold <= 1));
    //     return _executeCall(_to, _value, _data);
    // }

    // // TODO: Might be able to process the signatures as a single bytes array if they're a fixed length.
    // function executeCallSigned(address _to, uint256 _value, bytes _data, bytes _sig) external returns (bool) {
    //     require(_to != address(this) && _to != address(0));
    //     bytes32 message = getExecuteCallSignedMessage(_to, _value, _data);
    //     require(meetsSignerThreshold(message, _sig));
    //     return _executeCall(_to, _value, _data);
    // }

    // function _executeCall(address _to, uint256 _value, bytes _data) internal returns (bool success) {
    //     require(_to != address(this) && _to != address(0));

    //     // increment nonce to prevent reentrancy
    //     nonce++;

    //     // solium-disable-next-line security/no-inline-assembly
    //     assembly {
    //         success := call(gas, _to, _value, add(_data, 0x20), mload(_data), 0, 0)
    //     }

    //     emit CallExecuted(_to, _value, _data, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // function getExecuteCallSignedMessage(address _to, uint256 _value, bytes _data) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "executeCall", _to, _value, _data);
    // }

    // // TODO: Extract signature utils into npm module.

    // function recoverKey (
    //     bytes32 _hash, 
    //     bytes _sigs,
    //     uint256 _pos
    // ) private pure returns (address) {
    //     uint8 v;
    //     bytes32 r;
    //     bytes32 s;
    //     (v, r, s) = signatureSplit(_sigs, _pos);
    //     return ecrecover(
    //         _hash,
    //         v,
    //         r,
    //         s
    //     );
    // }

    // function signatureSplit(
    //     bytes _signatures,
    //     uint256 _pos
    // ) private pure returns (uint8 v, bytes32 r, bytes32 s) {
    //     uint256 offset = _pos * SIGNATURE_LENGTH;

    //     // solium-disable-next-line security/no-inline-assembly
    //     assembly {
    //         r := mload(add(_signatures, add(32, offset)))
    //         s := mload(add(_signatures, add(64, offset)))
    //         // Here we are loading the last 32 bytes, including 31 bytes
    //         // of 's'. There is no 'mload8' to do this.
    //         //
    //         // 'byte' is not working due to the Solidity parser, so lets
    //         // use the second best option, 'and'
    //         v := and(mload(add(_signatures, add(65, offset))), 0xff)
    //     }

    //     // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    //     if (v < 27) {
    //         v += 27;
    //     }

    //     require(v == 27 || v == 28);
    // }

}
