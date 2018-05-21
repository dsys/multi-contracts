const MultiSigIdentityFactory = artifacts.require('MultiSigIdentityFactory');
const MultiSigIdentity = artifacts.require('MultiSigIdentity');

contract('MultiSigIdentityFactory', (accounts) => {

  it('creates new MultiSigIdentity contracts', async () => {
    const factory = await MultiSigIdentityFactory.new()

    let result = await factory.create(accounts[0])
    assert.equal(result.logs.length, 1)
    assert.equal(result.logs[0].event, 'IdentityCreated')

    const identity = new MultiSigIdentity(result.logs[0].args._identity)
    result = await identity.getOwners.call()
    assert.deepEqual(result, [accounts[0]])
  })

})
