const SimpleIdentityProvider = artifacts.require("SimpleIdentityProvider");

contract('SimpleIdentityProvider', async (accounts) => {

  it("registers and unregister any Ethereum address", async () => {
    const instance = await SimpleIdentityProvider.deployed();

    let result = await instance.isRegisteredSelf.call({ from: accounts[0] })
    assert.isFalse(result.valueOf())

    result = await instance.isRegistered.call(accounts[1])
    assert.isFalse(result.valueOf())

    result = await instance.register("", { from: accounts[0] });
    assert.equal(result.logs.length, 1);
    assert.equal(result.logs[0].event, 'IdentityRegistered');
    assert.equal(result.logs[0].args.addr, accounts[0]);

    result = await instance.isRegisteredSelf.call({ from: accounts[0] })
    assert.isTrue(result.valueOf())

    result = await instance.isRegistered.call(accounts[1])
    assert.isFalse(result.valueOf())

    result = await instance.unregister({ from: accounts[0] })
    assert.equal(result.logs.length, 1);
    assert.equal(result.logs[0].event, 'IdentityUnregistered');
    assert.equal(result.logs[0].args.addr, accounts[0]);

    result = await instance.isRegisteredSelf.call({ from: accounts[0] })
    assert.isFalse(result.valueOf())

    result = await instance.isRegistered.call(accounts[1])
    assert.isFalse(result.valueOf())
  })

  it("supports multiple user registration", async () => {
    const instance = await SimpleIdentityProvider.deployed();

    let result = await instance.isRegisteredMany.call([accounts[0], accounts[1]]);
    assert.isFalse(result.valueOf())

    result = await instance.register("", { from: accounts[0] });

    result = await instance.isRegisteredMany.call([accounts[0], accounts[1]])
    assert.isFalse(result.valueOf())

    result = await instance.register("", { from: accounts[1] });

    result = await instance.isRegisteredMany.call([accounts[0], accounts[1]])
    assert.isTrue(result.valueOf())

    result = await instance.unregister({ from: accounts[0] })

    result = await instance.isRegisteredMany.call([accounts[0], accounts[1]])
    assert.isFalse(result.valueOf())

    result = await instance.isRegistered.call(accounts[0])
    assert.isFalse(result.valueOf())

    result = await instance.isRegistered.call(accounts[1])
    assert.isTrue(result.valueOf())
  })

})
