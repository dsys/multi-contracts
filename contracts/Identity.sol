pragma solidity ^0.4.24;

import { KeyManagement } from "./KeyManagement.sol";
import { SignatureUtils } from "solidity-sigutils/contracts/SignatureUtils.sol";

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

    using SignatureUtils for bytes32;
    using KeyManagement for KeyManagement.KeyManager;

    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event ExecutedSigned(bytes32 signHash, uint256 nonce, bool success);
    event ContractCreated(address newContract);
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
        return ( // solium-disable-line operator-whitespace
            _subject == address(this) ||
            manager.keyHasPurpose(bytes32(_subject), MANAGEMENT_KEY)
        );
    }

    /// @dev Returns whether or not a subject is able to perform actions on other contracts on behalf of the identity
    /// @param _subject The subject to check
    function isActionAddress(
        address _subject
    ) public view returns (bool) {
        return ( // solium-disable-line operator-whitespace
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
            "Last management key cannot remove itself"
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
    /// @param _to The contract that will be sent the message
    /// @param _messageHash The message hash to verify
    /// @param _messageSignatures The message signatures to verify
    function verifyMessageHash(
        address _to,
        bytes32 _messageHash,
        bytes _messageSignatures
    ) public {
        address[] memory addresses = _messageHash.recoverAddresses(_messageSignatures);
        for (uint256 i = 0; i < addresses.length; i++) {
            bytes32 keyId = bytes32(addresses[i]);
            // TODO: Add check for action keys
            if (manager.keyHasPurpose(keyId, MANAGEMENT_KEY)) {
                return;
            }
        }

        revert("No valid signatures provided");
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
            _to,
            messageHash.toEthBytes32SignedMessageHash(),
            _messageSignatures
        );

        // TODO: Check for valid nonce/timestamp

        nonce++; // increment nonce to prevent reentrancy

        uint256 _execGasLimit = _gasLimit == 0 ? gasleft() : _gasLimit;
        _execute(_to, _value, _data, _operationType, _execGasLimit);

        // TODO: Continue implementing ERC 1077.
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

    /// @dev Executes an operation on another contract
    /// @param _to The contract to call
    /// @param _value The value to attach to the call
    /// @param _data The data for the call
    /// @param _operationType The operation type for the call
    /// @param _gasLimit The gas limit to use for the call
    function _execute(
        address _to,
        uint256 _value,
        bytes _data,
        uint256 _operationType,
        uint256 _gasLimit
    ) internal returns (bool success) {
        if (_operationType == OPERATION_CALL) {
            success = _executeCall(_to, _value, _data, _gasLimit);
        } else if (_operationType == OPERATION_DELEGATECALL) {
            success = _executeDelegateCall(_to, _data, _gasLimit);
        } else if (_operationType == OPERATION_CREATE) {
            address newContract = _executeCreate(_data);
            success = newContract != 0;
            if (success) emit ContractCreated(newContract);
        } else {
            revert("Unsupported operation type");
        }
    }

    /// @dev Executes a call to another contract
    /// @param _to The contract to call
    /// @param _value The value to attach to the call
    /// @param _data The data for the call
    /// @param _gasLimit The gas limit to use for the call
    function _executeCall(
        address _to,
        uint256 _value,
        bytes _data,
        uint256 _gasLimit
    ) internal returns (bool success) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := call(_gasLimit, _to, _value, add(_data, 0x20), mload(_data), 0, 0)
        }
    }

    /// @dev Executes a delegatecall to another contract
    /// @param _to The contract to call
    /// @param _data The data for the call
    /// @param _gasLimit The gas limit to use for the call
    function _executeDelegateCall(
        address _to,
        bytes _data,
        uint256 _gasLimit
    ) internal returns (bool success) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := delegatecall(_gasLimit, _to, add(_data, 0x20), mload(_data), 0, 0)
        }
    }

    /// @dev Executes a create
    /// @param _data The data for the call
    function _executeCreate(
        bytes _data
    ) internal returns (address newContract) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            newContract := create(0, add(_data, 0x20), mload(_data))
        }
    }

}
