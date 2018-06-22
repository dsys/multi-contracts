const KeyManagement = artifacts.require("KeyManagement");
const IdentityFactory = artifacts.require("IdentityFactory");

module.exports = async function(deployer) {
  await deployer.deploy(KeyManagement)
  await deployer.deploy(IdentityFactory)
};
