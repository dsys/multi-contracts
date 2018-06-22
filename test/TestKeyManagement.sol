pragma solidity ^0.4.23;

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

        manager.addKey(0x123, 1, 2);
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0x123, "Keys can be added");
        Assert.equal(keyType, 2, "Keys have a key type");
        Assert.equal(purposes.length, 1, "Keys have purposes");
        Assert.equal(purposes[0], 1, "Keys have purposes");

        manager.addKey(0x456, 3, 4);
        (purposes, keyType, key) = manager.getKey(0x456);
        Assert.equal(key, 0x456, "Keys can be added");
        Assert.equal(keyType, 4, "Keys have a key type");
        Assert.equal(purposes.length, 1, "Keys have purposes");
        Assert.equal(purposes[0], 3, "Keys have purposes");

        manager.addKey(0x123, 2, 1);
        (purposes, keyType, key) = manager.getKey(0x123);
        Assert.equal(key, 0x123, "Keys can be added");
        Assert.equal(keyType, 1, "Keys have a key type");
        Assert.equal(purposes.length, 2, "Keys have purposes");
        Assert.equal(purposes[0], 1, "Keys have purposes");
        Assert.equal(purposes[1], 2, "Keys have purposes");
    }
}
