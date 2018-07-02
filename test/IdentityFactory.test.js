const IdentityFactory = artifacts.require("IdentityFactory");
const Identity = artifacts.require("Identity");
const { addressToBytes32 } = require("./helpers");

contract("IdentityFactory", accounts => {
  it("creates new Identity contracts", async () => {
    const factory = await IdentityFactory.new();

    let result = await factory.create(accounts[0]);
    assert.equal(result.logs.length, 1);
    assert.equal(result.logs[0].event, "IdentityCreated");

    const identity = new Identity(result.logs[0].args._identity);
    result = await identity.getKeysByPurpose(1);
    assert.deepEqual(result, [addressToBytes32(accounts[0])]);
  });
});
