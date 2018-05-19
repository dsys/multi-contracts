const MultiSigIdentity = artifacts.require('MultiSigIdentity');

contract('MultiSigIdentity', (accounts) => {

  it('has one owner when deployed', async () => {
    const identity = await MultiSigIdentity.new(accounts[0])

    let result = await identity.getOwners.call()
    assert.deepEqual(result, [accounts[0]])
  })

  describe('owners', () => {
    it('can add and remove other owners', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let result = await identity.addOwner(accounts[1], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerAdded');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0], accounts[1]])

      result = await identity.addOwner(accounts[2], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerAdded');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0], accounts[1], accounts[2]])

      result = await identity.removeOwner(accounts[1], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerRemoved');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0], accounts[2]])

      result = await identity.removeOwner(accounts[2], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerRemoved');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0]])
    })

    it('cannot add itself multiple times', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let result = await identity.addOwner(accounts[0], { from: accounts[0] })
      assert.equal(result.logs.length, 0);

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0]])
    })

    it('cannot remove itself if they are the last owner', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      try {
        await identity.removeOwner(accounts[0], { from: accounts[0] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'));
      }
    })

    it('can remove itself if it is not the last owner', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let result = await identity.addOwner(accounts[1], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerAdded');

      result = await identity.removeOwner(accounts[0], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerRemoved');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[1]])
    })

    it('can change owners using a signed message', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let msg = await identity.getAddOwnerSignedMessage.call(accounts[1]);
      let sig = web3.eth.sign(accounts[0], msg);

      let result = await identity.addOwnerSigned(accounts[1], sig, { from: accounts[1] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerAdded');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0], accounts[1]])

      msg = await identity.getRemoveOwnerSignedMessage.call(accounts[0]);
      sig = web3.eth.sign(accounts[1], msg);

      result = await identity.removeOwnerSigned(accounts[0], sig, { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'OwnerRemoved');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[1]])
    })

    it('cannot change owners with an invalid signature', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])
      const sig = web3.eth.sign(accounts[0], web3.sha3('notarealmessage'));
      let result

      try {
        result = await identity.addOwnerSigned(accounts[1], sig, { from: accounts[1] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'));
      }

      try {
        result = await identity.removeOwnerSigned(accounts[0], sig, { from: accounts[1] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'));
      }
    })

    it('cannot change owners with a signature from a non-owner', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      const msg = await identity.getAddOwnerSignedMessage.call(accounts[1]);
      const sig = web3.eth.sign(accounts[1], web3.sha3('notarealmessage'));
      let result

      try {
        result = await identity.addOwnerSigned(accounts[1], sig, { from: accounts[1] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'));
      }

      try {
        result = await identity.removeOwnerSigned(accounts[0], sig, { from: accounts[1] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'));
      }
    })
  })

  describe('everyone else', () => {
    it('cannot change owners', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      try {
        result = await identity.addOwner(accounts[1], { from: accounts[1] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'));
      }

      try {
        result = await identity.removeOwner(accounts[1], { from: accounts[1] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'));
      }
    })
  })

})
