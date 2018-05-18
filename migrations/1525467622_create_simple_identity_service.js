const ServiceRegistry = artifacts.require("ServiceRegistry");

module.exports = async function(deployer) {
  await deployer.deploy(ServiceRegistry)
};
