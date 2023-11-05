var main = artifacts.require("main");
var p2p = artifacts.require("p2p");

module.exports = async function(deployer) {
  await deployer.deploy(p2p);

  let addressp2p = await p2p.deployed()

  await deployer.deploy(main,addressp2p.address);
};
