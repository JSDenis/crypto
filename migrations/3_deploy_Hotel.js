const Hotel = artifacts.require("Hotel");
const Token = artifacts.require("Token");

module.exports = async function (deployer, networks, accounts) {
  const token = await Token.deployed()

  return deployer.deploy(Hotel, accounts[0], token.address, BigInt(10e18));
};
