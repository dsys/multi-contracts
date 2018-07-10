const SignatureUtils = artifacts.require("SignatureUtils");
const KeyManagement = artifacts.require("KeyManagement");
const Identity = artifacts.require("Identity");
const IdentityFactory = artifacts.require("IdentityFactory");

module.exports = async function(deployer) {
  await deployer.deploy(SignatureUtils);
  await deployer.link(SignatureUtils, [Identity, IdentityFactory]);
  await deployer.deploy(KeyManagement);
  await deployer.deploy(IdentityFactory);
};
