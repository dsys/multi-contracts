pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "../contracts/KeyManagement.sol";

contract TestKeyManagement {
    using KeyManagement for KeyManagement.KeyManager;

    KeyManagement.KeyManager manager;

    function beforeEach() public {
        manager = KeyManagement.KeyManager();
    }

    function testKeyGettersEmpty() public {
        uint256[] memory purposes;
        uint256 keyType;
        bytes32 key;
        bool exists;
        bytes32[] memory keys;

        (purposes, keyType, key) = manager.getKey(0x0);
        Assert.isZero(key, "All keys should be zero initially");

        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.isZero(key, "All keys should be zero initially");

        exists = manager.keyHasPurpose(0x0, 1);
        Assert.isFalse(exists, "Non-existant keys should not have any purposes");

        exists = manager.keyHasPurpose(0x123, 2);
        Assert.isFalse(exists, "Non-existant keys should not have any purposes");

        keys = manager.getKeysByPurpose(1);
        Assert.isZero(keys.length, "No keys exist for any purpose by default");

        keys = manager.getKeysByPurpose(2);
        Assert.isZero(keys.length, "No keys exist for any purpose by default");
    }

    function testKeyAddRemove() public {
        uint256[] memory purposes;
        uint256 keyType;
        bytes32 key;
        bytes32[] memory keys;
        bool success;

        // add key
        manager.addKey(0x123, 1, 2);
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0x123, "Keys can be added");
        Assert.equal(keyType, 2, "Keys have a key type");
        Assert.equal(purposes.length, 1, "Keys have purposes");
        Assert.equal(purposes[0], 1, "Keys have purposes");

        // add different key
        manager.addKey(0x456, 2, 4);
        (purposes, keyType, key) = manager.getKey(0x456);
        Assert.equal(key, 0x456, "Keys can be added");
        Assert.equal(keyType, 4, "Keys have a key type");
        Assert.equal(purposes.length, 1, "Keys have purposes");
        Assert.equal(purposes[0], 2, "Keys have purposes");

        // add key with extra purpose
        manager.addKey(0x123, 2, 1);
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0x123, "Keys can be added");
        Assert.equal(keyType, 1, "Keys have a key type");
        Assert.equal(purposes.length, 2, "Keys have purposes");
        Assert.equal(purposes[0], 1, "Keys have purposes");
        Assert.equal(purposes[1], 2, "Keys have purposes");

        // add key with existing purpose
        manager.addKey(0x123, 2, 1);
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0x123, "Keys can be added");
        Assert.equal(keyType, 1, "Keys have a key type");
        Assert.equal(purposes.length, 2, "Keys have purposes");
        Assert.equal(purposes[0], 1, "Keys have purposes");
        Assert.equal(purposes[1], 2, "Keys have purposes");

        keys = manager.getKeysByPurpose(1);
        Assert.equal(keys.length, 1, "Keys can be retrieved by purpose");
        Assert.equal(keys[0], 0x123, "Keys can be retrieved by purpose");

        keys = manager.getKeysByPurpose(2);
        Assert.equal(keys.length, 2, "Keys can be retrieved by purpose");
        Assert.equal(keys[0], 0x456, "Keys can be retrieved by purpose");
        Assert.equal(keys[1], 0x123, "Keys can be retrieved by purpose");

        keys = manager.getKeysByPurpose(3);
        Assert.equal(keys.length, 0, "Keys can be retrieved by purpose");

        // remove key
        success = manager.removeKey(0x123, 2);
        Assert.isTrue(success, "Key removal should succeed");
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0x123, "Keys can be added");
        Assert.equal(keyType, 1, "Keys have a key type");
        Assert.equal(purposes.length, 1, "Keys have purposes");
        Assert.equal(purposes[0], 1, "Keys have purposes");

        // remove key again
        success = manager.removeKey(0x123, 2);
        Assert.isFalse(success, "Key removal should fail");
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0x123, "Keys can be added");
        Assert.equal(keyType, 1, "Keys have a key type");
        Assert.equal(purposes.length, 1, "Keys have purposes");
        Assert.equal(purposes[0], 1, "Keys have purposes");

        // remove key
        success = manager.removeKey(0x123, 1);
        Assert.isTrue(success, "Key removal should succeed");
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0, "Key should no longer exist");

        // remove non-existant key
        success = manager.removeKey(0x123, 1);
        Assert.isFalse(success, "Key removal should fail");

        keys = manager.getKeysByPurpose(1);
        Assert.equal(keys.length, 0, "Keys can be retrieved by purpose");

        keys = manager.getKeysByPurpose(2);
        Assert.equal(keys.length, 1, "Keys can be retrieved by purpose");
        Assert.equal(keys[0], 0x456, "Keys can be retrieved by purpose");

        keys = manager.getKeysByPurpose(3);
        Assert.equal(keys.length, 0, "Keys can be retrieved by purpose");
    }
}
