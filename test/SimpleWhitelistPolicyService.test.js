const ServiceRegistry = artifacts.require("ServiceRegistry");
const SimpleIdentityService = artifacts.require("SimpleIdentityService");
const SimpleWhitelistPolicyService = artifacts.require("SimpleWhitelistPolicyService");

contract('SimpleWhitelistPolicyService', async (accounts) => {

  it("allows registered Ethereum addresses", async () => {
    const registry = await ServiceRegistry.deployed();
    const provider = await SimpleIdentityService.new(registry.address);
    const whitelist = await SimpleWhitelistPolicyService.new(provider.address);

    await provider.register("", { from: accounts[0] });

    let result = await whitelist.contract.check["address,address"].call(0x0, accounts[0])
    assert.equal(result, '0x00')

    result = await whitelist.contract.check["address,address"].call(0x0, accounts[1])
    assert.equal(result, '0x01')

    await provider.deregister({ from: accounts[0] });

    result = await whitelist.contract.check["address,address"].call(0x0, accounts[0])
    assert.equal(result, '0x01')

    result = await whitelist.contract.check["address,address"].call(0x0, accounts[1])
    assert.equal(result, '0x01')
  })

  it("allows registered pairs of Ethereum addresses", async () => {
    const registry = await ServiceRegistry.deployed();
    const provider = await SimpleIdentityService.new(registry.address);
    const whitelist = await SimpleWhitelistPolicyService.new(provider.address);

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

    await provider.deregister({ from: accounts[0] });

    result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[0], accounts[1], 0)
    assert.equal(result, '0x01')

    result = await whitelist.contract.check["address,address,address,uint256"].call(0x0, accounts[1], accounts[0], 0)
    assert.equal(result, '0x01')
  })

})
