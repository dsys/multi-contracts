const MultiSigIdentity = artifacts.require('MultiSigIdentity');

contract('MultiSigIdentity', (accounts) => {

  it('has one owner when deployed', async () => {
    const identity = await MultiSigIdentity.new(accounts[0])

    let result = await identity.getOwners.call()
    assert.deepEqual(result, [accounts[0]])
  })

  describe('owners and signer management', () => {
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

    it('can change signers', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let result = await identity.addSigner(accounts[1], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'SignerAdded');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0]])

      result = await identity.getSigners.call()
      assert.deepEqual(result, [accounts[1]])

      result = await identity.addSigner(accounts[2], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'SignerAdded');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0]])

      result = await identity.getSigners.call()
      assert.deepEqual(result, [accounts[1], accounts[2]])

      result = await identity.removeSigner(accounts[1], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'SignerRemoved');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0]])

      result = await identity.getSigners.call()
      assert.deepEqual(result, [accounts[2]])

      result = await identity.removeSigner(accounts[2], { from: accounts[0] })
      assert.equal(result.logs.length, 1);
      assert.equal(result.logs[0].event, 'SignerRemoved');

      result = await identity.getOwners.call()
      assert.deepEqual(result, [accounts[0]])

      result = await identity.getSigners.call()
      assert.deepEqual(result, [])
    })

    it('everyone else cannot change owners', async () => {
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

  describe('signer threshold configuration', () => {

    it('is 0 by default', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let result = await identity.getSignerThreshold.call()
      assert.equal(result, 0)
    })

    it('can be changed by owners', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let result = await identity.setSignerThreshold(2, { from: accounts[0] })
      assert.equal(result.logs.length, 1)
      assert.equal(result.logs[0].event, 'SignerThresholdChanged')

      result = await identity.getSignerThreshold.call()
      assert.equal(result, 2)

      const msg = await identity.getSetSignerThresholdSignedMessage.call(3);
      const sig = web3.eth.sign(accounts[0], msg);

      result = await identity.setSignerThresholdSigned(3, sig, { from: accounts[0] })
      assert.equal(result.logs.length, 1)
      assert.equal(result.logs[0].event, 'SignerThresholdChanged')

      result = await identity.getSignerThreshold.call()
      assert.equal(result, 3)
    })

    // TODO: Implement further tests relating to adding/removing signers.
    // TODO: Consider making compat with ERC 725.
  })

  describe('execution', () => {

    it('allows owners to execute calls', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      let result = await identity.executeCall(accounts[1], 0, "", { from: accounts[0] })
      assert.equal(result.logs.length, 1)
      assert.equal(result.logs[0].event, 'CallExecuted')
    })

    it('allows owners to execute calls using a signature', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      const msg = await identity.getExecuteCallSignedMessage.call(accounts[1], 0, "");
      const sig = web3.eth.sign(accounts[0], msg);

      let result = await identity.executeCallSigned(accounts[1], 0, "", sig, { from: accounts[0] })
      assert.equal(result.logs.length, 1)
      assert.equal(result.logs[0].event, 'CallExecuted')
    })

    it('allows signers to execute calls using a signature if they meet the threshold', async () => {
      const identity = await MultiSigIdentity.new(accounts[0])

      await identity.setSignerThreshold(2)
      await identity.addSigner(accounts[1], { from: accounts[0] })
      await identity.addSigner(accounts[2], { from: accounts[0] })
      await identity.addSigner(accounts[3], { from: accounts[0] })

      let msg = await identity.getExecuteCallSignedMessage.call(accounts[4], 0, "");
      let sig1 = web3.eth.sign(accounts[1], msg) + '00000000000000';
      let sig2 = web3.eth.sign(accounts[2], msg) + '00000000000000';
      let sig3 = web3.eth.sign(accounts[3], msg) + '00000000000000';
      let sigCombined = sig1 + sig2.substring(2) + sig3.substring(2)
      let result = await identity.executeCallSigned(accounts[4], 0, "", sigCombined, { from: accounts[4] })
      assert.equal(result.logs.length, 1)
      assert.equal(result.logs[0].event, 'CallExecuted')

      msg = await identity.getExecuteCallSignedMessage.call(accounts[4], 0, "");
      sig1 = web3.eth.sign(accounts[1], msg) + '00000000000000';
      sig2 = web3.eth.sign(accounts[2], msg) + '00000000000000';
      sigCombined = sig1 + sig2.substring(2);
      result = await identity.executeCallSigned(accounts[4], 0, "", sigCombined, { from: accounts[4] })
      assert.equal(result.logs.length, 1)
      assert.equal(result.logs[0].event, 'CallExecuted')

      msg = await identity.getExecuteCallSignedMessage.call(accounts[4], 0, "");
      sig1 = web3.eth.sign(accounts[1], msg) + '00000000000000';
      sig2 = web3.eth.sign(accounts[2], msg) + '00000000000000';
      sigCombined = sig2 + sig1.substring(2)
      result = await identity.executeCallSigned(accounts[4], 0, "", sigCombined, { from: accounts[4] })
      assert.equal(result.logs.length, 1)
      assert.equal(result.logs[0].event, 'CallExecuted')

      try {
        msg = await identity.getExecuteCallSignedMessage.call(accounts[4], 0, "");
        sig1 = web3.eth.sign(accounts[1], msg) + '00000000000000';
        result = await identity.executeCallSigned(accounts[4], 0, "", sig1, { from: accounts[4] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'))
      }

      try {
        msg = await identity.getExecuteCallSignedMessage.call(accounts[4], 0, "");
        sig2 = web3.eth.sign(accounts[2], msg) + '00000000000000';
        result = await identity.executeCallSigned(accounts[4], 0, "", sig2, { from: accounts[4] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'))
      }

      try {
        msg = await identity.getExecuteCallSignedMessage.call(accounts[4], 0, "");
        sig1 = web3.eth.sign(accounts[1], msg) + '00000000000000';
        sigCombined = sig1 + sig1.substring(2)
        result = await identity.executeCallSigned(accounts[4], 0, "", sigCombined, { from: accounts[4] })
        assert.fail('expected throw not received');
      } catch (err) {
        assert(err.message.search('revert'))
      }
    })

  })

})
