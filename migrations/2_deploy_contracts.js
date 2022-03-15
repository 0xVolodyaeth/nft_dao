const dao = artifacts.require("DAO");

module.exports = function (deployer) {
	deployer.deploy(dao);
};