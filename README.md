# Alchemy Road to Web-3 Week 6 + 🏗 scaffold-eth | 🏰 BuidlGuidl

[SpeedRunEthereum](https://speedrunethereum.com/challenge/decentralized-staking), [Alchemy Road to Web 3](https://docs.alchemy.com/docs/how-to-build-a-staking-dapp), [Scaffold-eth Repo sample](https://github.com/scaffold-eth/scaffold-eth)

## Notes

- For testing added static analyzer [Slither](https://github.com/crytic/slither) for Solidity code. Run following command:

```bash

yarn slither

```
- If you want to write unit tests for your solidity code and check coverage of tests, run command:

```bash

yarn coverage

```
- Added gas reporter for solidity. After running `yarn deploy`, you can check report at `packages/hardhat/gas-report.txt`.

- Add your own api keys and private key by using `.env` file at `packages/hardhat/.example.env`.

## Install

```bash

git clone https://github.com/AnastasiaMenshikova/challenge-1-decentralized-staking

cd challenge-1-decentralized-staking

git checkout challenge-1-decentralized-staking

yarn install

```

## How to use

You'll need 3 terminals up and running.

```bash

yarn start   (react app frontend)
yarn chain   (hardhat backend)
yarn deploy  (to compile, deploy, and publish your contracts to the frontend)

```
Rerun `yarn deploy --reset` whenever you want to deploy new contracts to the frontend.

If you're going to deploy smart contracts to testnet (`goerli` or `rinkeby`) use:
 
 ```bash
 
 yarn deploy --network <YOUR_NETWORK>

 ```
 
 For verifying contracts on Etherscan run:
 
  ```bash
 
 yarn verify --network <YOUR_NETWORK>

 ```

Edit the `targetNetwork` in `App.jsx` (in `packages/react-app/src`) to be the public network where you deployed your smart contract.

When you are ready to ship the frontend app, run `yarn build` to package up your frontend.

Upload your app to surge with `yarn surge` (you could also use `yarn s3` or `yarn ipfs`). If you get a permissions error `yarn surge` again until you get a unique URL, or customize it in the command line.