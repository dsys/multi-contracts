pragma solidity ^0.4.23;

/// @title KeyManagement
/// @author Alex Kern <alex@distributedsystems.com>
library KeyManagement {

    struct Key {
        uint256[] purposes;
        uint256 keyType;
        bytes32 key;
    }

    struct KeyManager {
        mapping (bytes32 => Key) allKeys;
        mapping (uint256 => bytes32[]) keysByPurpose;
    }

    function getKey(KeyManager storage self, bytes32 _key) internal view returns (uint256[] purposes, uint256 keyType, bytes32 key) {
        Key memory k = self.allKeys[_key];
        purposes = k.purposes;
        keyType = k.keyType;
        key = k.key;
    }

    function keyHasPurpose(KeyManager storage self, bytes32 _key, uint256 _purpose) internal view returns (bool) {
        Key memory k = self.allKeys[_key];
        uint256 l = k.purposes.length;
        for (uint256 i; i < l; i++) {
            if (_purpose == k.purposes[i]) return true;
        }
        return false;
    }

    function getKeysByPurpose(KeyManager storage self, uint256 _purpose) public view returns (bytes32[]) {
        return self.keysByPurpose[_purpose];
    }

    function addKey(KeyManager storage self, bytes32 _key, uint256 _purpose, uint256 _keyType) public returns (bool) {
        uint256 i;
        uint256[] memory purposes;

        Key storage k = self.allKeys[_key];

        // create key
        if (k.key == 0) {
            purposes = new uint256[](1);
            purposes[0] = _purpose;
            self.allKeys[_key] = Key(purposes, _keyType, _key);
            return true;
        }

        if (k.key != _key) {
            k.key = _key;
        }

        if (k.keyType != _keyType) {
            k.keyType = _keyType;
        }
        
        bool purposeFound = false;
        uint256 l = k.purposes.length;
        for (; i < l; i++) {
            if (k.purposes[i] == _purpose) {
                purposeFound = true;
                break;
            }
        }

        if (!purposeFound) {
            purposes = new uint256[](l + 1);
            for (i = 0; i < l; i++) {
                purposes[i] = k.purposes[i];
            }
            purposes[l] = _purpose;
            k.purposes = purposes;
        }

        return true;
    }

    function removeKey(KeyManager storage self, bytes32 _key, uint256 _purpose) returns (bool) {

    }

}
