require("@nomicfoundation/hardhat-toolbox");
// require("./tasks");

module.exports = {
  networks: {
    localhost: {
      chainId: 31337,
    },
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
