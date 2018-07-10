exports.addressToBytes32 = address => {
  let bytes32 = address.substring(2);
  while (bytes32.length < 64) bytes32 = "0" + bytes32;
  return "0x" + bytes32;
};

exports.assertRevert = promise => {
  return promise.then(
    () => {
      assert(false, "transaction should be reverted");
    },
    err => {
      assert.match(err.toString(), /revert/);
    }
  );
};
