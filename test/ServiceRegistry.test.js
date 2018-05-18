const ServiceRegistry = artifacts.require('ServiceRegistry');
const MockService = artifacts.require('MockService');

const MockServiceInterfaceHash = web3.sha3('com.cleargraph.MockService')
const OtherServiceInterfaceHash = web3.sha3('com.cleargraph.OtherService')

contract('ServiceRegistry', async (accounts) => {

  it("cannot find an unknown service", async () => {
    const registry = await ServiceRegistry.new({ from: accounts[0] });

    let result = await registry.contract.supportsService['string'].call("foo")
    assert.isFalse(result)

    result = await registry.contract.supportsService['string,bytes32'].call("foo", MockServiceInterfaceHash)
    assert.isFalse(result)

    result = await registry.contract.discoverService['string'].call("foo")
    assert.equal(result, 0)

    result = await registry.contract.discoverService['string,bytes32'].call("foo", MockServiceInterfaceHash)
    assert.equal(result, 0)
  })

  it("finds known services", async () => {
    const registry = await ServiceRegistry.new({ from: accounts[0] });
    const mockService = await MockService.new();

    let result = await registry.setService('foo', mockService.address, { from: accounts[0] })
    assert.equal(result.logs.length, 1)
    assert.equal(result.logs[0].event, 'ServiceSet')

    result = await registry.contract.discoverService['string'].call("foo")
    assert.equal(result, mockService.address)

    result = await registry.contract.discoverService['string'].call("baz")
    assert.equal(result, 0)

    result = await registry.contract.discoverService['string,bytes32'].call("foo", MockServiceInterfaceHash)
    assert.equal(result, mockService.address)

    result = await registry.contract.discoverService['string,bytes32'].call("foo", OtherServiceInterfaceHash)
    assert.equal(result, 0)

    result = await registry.contract.discoverService['string,bytes32'].call("baz", MockServiceInterfaceHash)
    assert.equal(result, 0)

    result = await registry.contract.supportsService['string'].call("foo")
    assert.isTrue(result)

    result = await registry.contract.supportsService['string,bytes32'].call("foo", MockServiceInterfaceHash)
    assert.isTrue(result)

    result = await registry.contract.supportsService['string,bytes32'].call("foo", OtherServiceInterfaceHash)
    assert.isFalse(result)

    result = await registry.contract.supportsService['string'].call("bar")
    assert.isFalse(result)

    result = await registry.contract.supportsService['string,bytes32'].call("baz", MockServiceInterfaceHash)
    assert.isFalse(result)

    result = await registry.deleteService('foo', { from: accounts[0] })
    assert.equal(result.logs.length, 1)
    assert.equal(result.logs[0].event, 'ServiceDeleted')

    result = await registry.contract.discoverService['string'].call("foo")
    assert.equal(result, 0)

    result = await registry.contract.discoverService['string,bytes32'].call("foo", MockServiceInterfaceHash)
    assert.equal(result, 0)

    result = await registry.contract.discoverService['string,bytes32'].call("foo", OtherServiceInterfaceHash)
    assert.equal(result, 0)

    result = await registry.contract.supportsService['string'].call("foo")
    assert.isFalse(result)

    result = await registry.contract.supportsService['string,bytes32'].call("foo", MockServiceInterfaceHash)
    assert.isFalse(result)

    result = await registry.contract.supportsService['string,bytes32'].call("foo", OtherServiceInterfaceHash)
    assert.isFalse(result)
  })

})
