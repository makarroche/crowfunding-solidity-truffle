const Crowfund = artifacts.require("Crowfund");

module.exports = function (deployer) {
  deployer.deploy(Crowfund, "Crowfund");
};