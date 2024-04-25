# Ethereum Proof-of-Stake Devnet with deployment of the EigenLayer contracts

## Introduction

This repository is a fork of the [POS DevNet](https://github.com/ivy-net/eth-pos-devnet) repository, extended by an automatic deployment of the EigenLayer contracts.

## Quick Start

Ensure that you have docker and packer installed and docker daemon is running.

Build the image with packer
```
cd eigenlayer
packer init .
packer build -var 'version=0.5' .
```
Start docker compose

NOTE: If you experience hangs in the compilation or build process, update docker to the latest version
```
cd ../
./clean.sh
docker-compose up -d
```
Check logs of the eigenlayer container to confirm that all the contracts have been deployed successfully:
```
docker-compose logs eigenlayer
```

## Docker image to deploy EigneLayer

The docker image to deploy the EigenLayer contracts bases on the [Foundry](https://book.getfoundry.sh/tutorials/foundry-docker) one.
During the build process the image is enriched by addition of the compile smart contracts from the EigenLayer Contracts and EigenLayer Middleware repositories.

The image is prepared with the [packer](https://www.packer.io/) tool by HashiCorp.
It is defined in the [eigenlayer-deploy.pkr.hcl](eigenlayer/eigenlayer-deploy.pkr.hcl) file.
The file can be easily extended (e.g. by addition of the AVS contracts).

## Extension of docker-compose

There are a few small adjustment to the original docker-compose code.
The most obvious one is addition of the new image with the EL code.
To enable deployment there are also small tweaks in the geth container definition.
Firstly, the healthcheck block is added.
It is to give time for blockchain to settle, before publishing the EL contracts.
Additionally, the insecure http connections are permitted from the remote hosts.
This change enables forge (from the foundry image) to deployed the code.


## Ethereum Proof-of-Stake Devnet

This repository based on the [Etherum POS DevNet](https://github.com/ivy-net/eth-pos-devnet) which is a updated fork of the [original OffchainLabs](https://github.com/OffchainLabs/eth-pos-devnet) work.
Please check documentation there for more information.
Below you can find the key feature listed.

### Available Features

- Starts from the Capella Ethereum hard fork
- The network launches with a [Validator Deposit Contract](https://github.com/ethereum/consensus-specs/blob/dev/solidity_deposit_contract/deposit_contract.sol) deployed at address `0x4242424242424242424242424242424242424242`. This can be used to onboard new validators into the network by depositing 32 ETH into the contract
- The default account used in the go-ethereum node is address `0x123463a4b065722e99115d6c222f267d9cabb524` with private key `0xfad2709d0bb03bf0e8ba3c99bea194575d3e98863133d1af638ed056d1d59345` which comes seeded with ETH for use in the network. This can be used to send transactions, deploy contracts, and more
- The default account, `0x123463a4b065722e99115d6c222f267d9cabb524` is also set as the fee recipient for transaction fees proposed validators in Prysm. This address will be receiving the fees of all proposer activity
- The go-ethereum JSON-RPC API is available at http://geth:8545
- The Prysm client's REST APIs are available at http://beacon-chain:3500. For more info on what these APIs are, see [here](https://ethereum.github.io/beacon-APIs/)
- The Prysm client also exposes a gRPC API at http://beacon-chain:4000
