const SimpleIdentityProvider = artifacts.require("SimpleIdentityProvider");

module.exports = function(deployer) {
  deployer.deploy(SimpleIdentityProvider)
};
