const PrivateKeyProvider = require('truffle-privatekey-provider');

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: () => new PrivateKeyProvider(process.env.INFURA_PRIVATE_KEY, `https://ropsten.infura.io/${process.env.INFURA_API_KEY}`),
      network_id: 4,
      gas: 4612388 // Gas limit used for deploys
    }
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD'
    }
  }

  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
};
