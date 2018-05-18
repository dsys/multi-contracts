const ClaimRegistry = artifacts.require('ClaimRegistry');

contract('ClaimRegistry', async (accounts) => {

  it('can perform self-claims', async () => {
    const registry = await ClaimRegistry.new();

    let result = await registry.hasClaim.call(accounts[0], accounts[0], 'foo')
    assert.isFalse(result)

    result = await registry.hasClaim.call(accounts[0], accounts[0], 'bar')
    assert.isFalse(result)

    result = await registry.getClaim.call(accounts[0], accounts[0], 'foo')
    assert.equal(result, 0)

    result = await registry.setClaim(accounts[0], accounts[0], 'foo', '0x1111111111111111111111111111111111111111111111111111111111111111')
    assert.equal(result.logs.length, 1)
    assert.equal(result.logs[0].event, 'ClaimSet')

    result = await registry.hasClaim.call(accounts[0], accounts[0], 'foo')
    assert.isTrue(result)

    result = await registry.hasClaim.call(accounts[0], accounts[0], 'bar')
    assert.isFalse(result)

    result = await registry.getClaim.call(accounts[0], accounts[0], 'foo')
    assert.equal(result, '0x1111111111111111111111111111111111111111111111111111111111111111')

    result = await registry.setClaim(accounts[0], accounts[0], 'foo', '0x2222222222222222222222222222222222222222222222222222222222222222')
    assert.equal(result.logs.length, 1)
    assert.equal(result.logs[0].event, 'ClaimSet')

    result = await registry.hasClaim.call(accounts[0], accounts[0], 'foo')
    assert.isTrue(result)

    result = await registry.hasClaim.call(accounts[0], accounts[0], 'bar')
    assert.isFalse(result)

    result = await registry.getClaim.call(accounts[0], accounts[0], 'foo')
    assert.equal(result, '0x2222222222222222222222222222222222222222222222222222222222222222')

    result = await registry.removeClaim(accounts[0], accounts[0], 'foo')
    assert.equal(result.logs.length, 1)
    assert.equal(result.logs[0].event, 'ClaimRemoved')

    result = await registry.hasClaim.call(accounts[0], accounts[0], 'foo')
    assert.isFalse(result)

    result = await registry.hasClaim.call(accounts[0], accounts[0], 'bar')
    assert.isFalse(result)

    result = await registry.getClaim.call(accounts[0], accounts[0], 'foo')
    assert.equal(result, 0)
  })

})
