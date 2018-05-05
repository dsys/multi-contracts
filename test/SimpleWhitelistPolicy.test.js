const SimpleIdentityProvider = artifacts.require("SimpleIdentityProvider");
const SimpleWhitelistPolicy = artifacts.require("SimpleWhitelistPolicy");

contract('SimpleWhitelistPolicy', async (accounts) => {

  it("allows registered Ethereum addresses", async () => {
    const provider = await SimpleIdentityProvider.deployed();
    const whitelist = await SimpleWhitelistPolicy.new(provider.address);

    await provider.register("", { from: accounts[0] });

    let result = await whitelist.contract.check["address,address"].call(0x0, accounts[0])
    assert.equal(result, '0x00')

    result = await whitelist.contract.check["address,address"].call(0x0, accounts[1])
    assert.equal(result, '0x01')

    await provider.unregister({ from: accounts[0] });

    result = await whitelist.contract.check["address,address"].call(0x0, accounts[0])
    assert.equal(result, '0x01')

    result = await whitelist.contract.check["address,address"].call(0x0, accounts[1])
    assert.equal(result, '0x01')
  })


  it("allows registered pairs of Ethereum addresses", async () => {
    const provider = await SimpleIdentityProvider.deployed();
    const whitelist = await SimpleWhitelistPolicy.new(provider.address);

    await provider.register("", { from: accounts[0] });

    let result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[0], accounts[1], 0)
    assert.equal(result, '0x01')

    result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[1], accounts[0], 0)
    assert.equal(result, '0x01')

    await provider.register("", { from: accounts[1] });

    result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[0], accounts[1], 0)
    assert.equal(result, '0x00')

    result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[1], accounts[0], 0)
    assert.equal(result, '0x00')

    await provider.unregister({ from: accounts[0] });

    result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[0], accounts[1], 0)
    assert.equal(result, '0x01')

    result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[1], accounts[0], 0)
    assert.equal(result, '0x01')
  })

})
