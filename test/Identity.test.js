const Identity = artifacts.require("Identity");
const { addressToBytes32, assertRevert } = require("./helpers");

contract("Identity", accounts => {
  let identity;
  let result;

  beforeEach(async () => {
    identity = await Identity.new(accounts[0]);
  });

  describe("upon deployment", () => {
    it("has one owner when deployed", async () => {
      result = await identity.getKeysByPurpose(1);
      assert.deepEqual(result, [addressToBytes32(accounts[0])]);

      result = await identity.getKey(addressToBytes32(accounts[0]));
      assert.equal(result[0].length, 1);
      assert.equal(result[0][0].toNumber(), 1);
      assert.equal(result[1].toNumber(), 1);
      assert.equal(result[2], addressToBytes32(accounts[0]));

      result = await identity.keyHasPurpose(addressToBytes32(accounts[0]), 1);
      assert.isTrue(result);

      result = await identity.keyHasPurpose(addressToBytes32(accounts[0]), 2);
      assert.isFalse(result);
    });

    it("has a nonce of 0", async () => {
      result = await identity.lastNonce();
      assert.equal(0, result);
    });
  });

  describe("key management", () => {
    it("manager addresses can manage keys", async () => {
      result = await identity.addKey(addressToBytes32(accounts[1]), 1, 1);
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, "KeyAdded");

      result = await identity.getKeysByPurpose(1);
      assert.deepEqual(result, [
        addressToBytes32(accounts[0]),
        addressToBytes32(accounts[1])
      ]);

      result = await identity.removeKey(addressToBytes32(accounts[1]), 1);
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, "KeyRemoved");

      result = await identity.getKeysByPurpose(1);
      assert.deepEqual(result, [addressToBytes32(accounts[0])]);
    });

    it("the last manager cannot remove itself", async () => {
      await assertRevert(identity.removeKey(addressToBytes32(accounts[0]), 1));

      result = await identity.addKey(addressToBytes32(accounts[1]), 1, 1);
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, "KeyAdded");

      result = await identity.removeKey(addressToBytes32(accounts[0]), 1);
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, "KeyRemoved");
    });

    it("non-manager addresses cannot manage keys", async () => {
      await assertRevert(
        identity.addKey(addressToBytes32(accounts[1]), 1, 1, {
          from: accounts[1]
        })
      );

      await assertRevert(
        identity.removeKey(addressToBytes32(accounts[1]), 1, {
          from: accounts[1]
        })
      );
    });
  });

  describe("executing signed messages", () => {
    it("correctly hashes messages", async () => {
      // prettier-ignore
      const messageHash = await identity.getMessageHash(
        "0x1111111111111111111111111111111111111111", // to
        "0x2222222222222222222222222222222222222222", // from
        0,                                            // value
        "0x0",                                        // data
        1,                                            // nonce
        0,                                            // gasPrice
        0,                                            // gasPrice
        0,                                            // gasToken
        0,                                            // operationType
        ""                                            // extraHash
      );

      assert.equal(
        messageHash,
        "0x6a361345b71bdab7c1f915e006cd3694fac0aa0d6ee3a13b85b0ad6970a93b8d"
      );
    });

    it("executes signed messages from management keys", async () => {
      const args = [
        identity.address, // to
        identity.address, // from
        0, // value
        identity.contract.addKey.getData(addressToBytes32(accounts[1]), 1, 1), // data
        1, // nonce
        0, // gasPrice
        0, // gasPrice
        0, // gasToken
        0, // operationType
        "" // extraHash
      ];

      const messageHash = await identity.getMessageHash(...args);
      const messageSignature = web3.eth.sign(
        accounts[0],
        messageHash.substring(2)
      );

      result = await identity.executeSigned(...args, messageSignature);
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, "KeyAdded");
    });

    it("does not execute signed messages with invalid signatures", async () => {
      const args = [
        identity.address, // to
        identity.address, // from
        0, // value
        identity.contract.addKey.getData(addressToBytes32(accounts[1]), 1, 1), // data
        1, // nonce
        0, // gasPrice
        0, // gasPrice
        0, // gasToken
        0, // operationType
        "" // extraHash
      ];

      await assertRevert(identity.executeSigned(...args, "0xabcdef"));
    });

    it("does not execute signed messages from action keys that operate on the contract itself", async () => {
      await identity.addKey(addressToBytes32(accounts[1]), 2, 1);

      const args = [
        identity.address, // to
        identity.address, // from
        0, // value
        identity.contract.addKey.getData(addressToBytes32(accounts[1]), 1, 1), // data
        1, // nonce
        0, // gasPrice
        0, // gasPrice
        0, // gasToken
        0, // operationType
        "" // extraHash
      ];

      const messageHash = await identity.getMessageHash(...args);
      const messageSignature = web3.eth.sign(accounts[1], messageHash);

      await assertRevert(identity.executeSigned(...args, messageSignature));
    });
  });
});
