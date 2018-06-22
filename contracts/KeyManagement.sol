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
        Key storage k = self.allKeys[_key];
        uint256 l = k.purposes.length;
        for (uint256 i; i < l; i++) {
            if (_purpose == k.purposes[i]) return true;
        }
        return false;
    }

    function getKeysByPurpose(KeyManager storage self, uint256 _purpose) internal view returns (bytes32[]) {
        return self.keysByPurpose[_purpose];
    }

    function addKey(KeyManager storage self, bytes32 _key, uint256 _purpose, uint256 _keyType) internal returns (bool) {
        Key storage k = self.allKeys[_key];

        if (k.key == 0) {
            uint256[] memory purposes = new uint256[](1);
            purposes[0] = _purpose;
            self.allKeys[_key] = Key(purposes, _keyType, _key);
            self.keysByPurpose[_purpose].push(_key);
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
        for (uint256 i; i < l; i++) {
            if (k.purposes[i] == _purpose) {
                purposeFound = true;
                break;
            }
        }

        if (!purposeFound) {
            k.purposes.push(_purpose);
            self.keysByPurpose[_purpose].push(_key);
        }

        return true;
    }

    function removeKey(KeyManager storage self, bytes32 _key, uint256 _purpose) internal returns (bool) {
        bytes32[] storage keys = self.keysByPurpose[_purpose];

        uint256 l = keys.length;
        if (l == 0) return false;

        bool keyFound = false;
        uint256 i;

        for (; i < l; i++) {
            if (keys[i] == _key) {
                keyFound = true;
                if (i != l - 1) {
                    keys[i] = keys[l - 1];
                }
                keys.length--;
                break;
            }
        }

        if (!keyFound) return false;

        Key storage k = self.allKeys[_key];
        l = k.purposes.length;
        if (l == 1) {
            delete self.allKeys[_key];
            return true;
        }

        for (i = 0; i < l; i++) {
            if (k.purposes[i] == _purpose) {
                k.purposes[i] = k.purposes[l - 1];
                k.purposes.length--;
                return true;
            }
        }

        assert(false);
    }

}
