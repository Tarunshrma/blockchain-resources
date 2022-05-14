const StarNotary = artifacts.require("starNotary");

module.exports = function(deployer) {
  deployer.deploy(StarNotary);
};
