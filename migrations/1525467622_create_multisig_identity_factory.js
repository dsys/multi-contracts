const MultiSigIdentityFactory = artifacts.require("MultiSigIdentityFactory");

module.exports = async function(deployer) {
  await deployer.deploy(MultiSigIdentityFactory)
};
