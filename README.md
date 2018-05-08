# Cleargraph's Solidity smart contracts

For the Ethereum Virtual Machine.

**Service** is a generic introspectable service on the Ethereum blockchain. **IdentityProvider** provides a generic interface for both registering identities and discovering services supported by registered identities. There are many ways to implement identity providers using this scaffolding.

The proposed implementation supports any address-based identity system, such as uPort's Proxy contract, ERC 725, or raw Ethereum addresses.

## Development

    $ yarn install
    $ yarn run migrate
    $ yarn start

## Testing

    $ yarn test
    $ yarn run watch # requires watchman: brew install watchman

### Static analysis with Mythril

    $ make install-mythril
    $ make myth
