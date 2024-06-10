# Ethereum Proof-of-Stake Devnet with deployment of the EigenLayer contracts

## Introduction

This repository is a fork of the [POS DevNet](https://github.com/ivy-net/eth-pos-devnet) repository, extended by an automatic deployment of the EigenLayer contracts.

## Quick Start

### Preapre images
Ensure that you have docker and packer installed and docker daemon is running.

Build the images with packer
```
cd packer
packer init .
packer build -var 'version=0.9' .
```
_NOTE: The proces might take 10--15 minutes, depends on hardware._

There will be 2 images prepared:
* iv1-dev - contains the latest dev build of EigenLayer contracts
* iv1-avs - contains the above and Incredible Squaring AVS pre-build contracts

### Start docker compose
There are two docker-compose configuration files.
The first one is to deploys the POS network with the EigenLayer only.
The second one adds the demo AVS to the network, but uses the older version of theEigenLayer.
It is because the AVS does not work the latest EigenLayer code.

_NOTE: If you experience hangs in the compilation or build process, update docker to the latest version._


#### EigenLayer only

To deploy POS network only with EigenLayer contracts follow these steps:
```
cd ../
./clean.sh
docker-compose -f docker-compose-dev.yml up -d
```
Check logs of the eigenlayer container to confirm that all the contracts have been deployed successfully:
```
docker-compose -f docker-compose-dev.yml logs eigenlayer
```

#### Incredible Squaring AVS

To deploy the POS network with EigenLayer and Incredible Squaring AVS contracts follow these steps:
```
cd ../
./clean.sh
docker-compose -f docker-compose-avs.yml up -d
```
Check logs of the eigenlayer, avs-demo and cast containers to confirm that all the contracts have been deployed successfully and ether has been transferred:
```
docker-compose -f docker-compose-avs.yml logs eigenlayer
docker-compose -f docker-compose-avs.yml logs avs-demo
docker-compose -f docker-compose-avs.yml logs cast
```

### Deploy Incredible Squaring AVS

To code of the Incredible Squaring AVS is require to continue.
It can be found in the Ivy-Net fork [Incredible Squaring AVS](https://github.com/ivy-net/incredible-squaring-avs/tree/master).
(_The fork is required only for one commit, which has been approved, but not yet merged._)

```
cd ../
git clone https://github.com/ivy-net/incredible-squaring-avs.git
```
If the incredible-squaring-avs folder is present ensure that it points at code from the ivy-net reposity

#### Only for the simple Eigenlayer deployment

_Please skip following steps if the docker-compose-avs.yml file was used above._

* After docker-compose finishes deployment run following command from the _contracts_ folder of the Incredible Squaring AVS.
```
cd incredible-squaring-avs/contracts
```
```
forge script script/IncredibleSquaringDeployer.s.sol \
 --rpc-url http://localhost:8545 \
 --broadcast \
 --unlocked \
 --sender 0x123463a4b065722e99115d6c222f267d9cabb524
```
* The next step is to top up the operator account. To do this run following command:
```
cast send 0x860B6912C2d0337ef05bbC89b0C2CB6CbAEAB4A5 --value 10ether --private-key 0x2e0834786285daccd064ca17f1654f67b4aef298acbb82cef9ec422fb4975622
```
or use the make command (from the main folder of the AVS repo):
```
make \
  DEPLOYER_PRIVATE_KEY=0x2e0834786285daccd064ca17f1654f67b4aef298acbb82cef9ec422fb4975622 \
  CHAINID=32382 \
  send-fund
```
* Change current directory to make easier to copy data
```
cd ../
```

#### Common steps
* Copy config files specific for the POS chain to the `config-files` folder in the Incredible Squaring AVS.
The files are located in the incredible-squaring-avs/32382 subfolder of the iv1 repository.
```
cp -r  iv1/incredible-squaring-avs/32382 incredible-squaring-avs/config-files
```
* Additionally, the output of the AVS smart contracts deployment needs to be copied:
```
mkdir -p incredible-squaring-avs/contracts/script/output/32382/
cp iv1/eigenlayer/incredible.json incredible-squaring-avs/contracts/script/output/32382/credible_squaring_avs_deployment_output.json
```
* With the filed copied over, off-chain component of the AVS can be started with the following commands.
Please note, that they have to be run in the main folder of the AVS project.
```
cd incredible-squaring-avs
```
* Start Aggregator with:

* Finally, start the aggregator:
```
make CHAINID=32382 start-aggregator
```
* and Operator (by running following command in the new terminal):
```
make CHAINID=32382 start-operator
```

The logs should appear in both terminal.
Some of the tasks might not be validate properly, because of a timing issue.
This problem is unique to the POS network.

At the end stop docker images with appropriate command:
* for eignelayer only deployment:
```
docker-compose -f docker-compose-dev.yml down
```
* for the AVS + EL deployment:
```
docker-compose -f docker-compose-avs.yml down
```

## Docker image to deploy EigneLayer

The docker image to deploy the EigenLayer contracts bases on the [Foundry](https://book.getfoundry.sh/tutorials/foundry-docker) one.
During the build process the image is enriched by addition of the compile smart contracts from the EigenLayer Contracts and EigenLayer Middleware repositories.

The image is prepared with the [packer](https://www.packer.io/) tool by HashiCorp.
It is defined in the [eigenlayer-deploy.pkr.hcl](packer/eigenlayer-deploy.pkr.hcl) file.
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
- The default account used in the go-ethereum node is address `0x123463a4b065722e99115d6c222f267d9cabb524` with private key `0x2e0834786285daccd064ca17f1654f67b4aef298acbb82cef9ec422fb4975622` which comes seeded with ETH for use in the network. This can be used to send transactions, deploy contracts, and more
- The default account, `0x123463a4b065722e99115d6c222f267d9cabb524` is also set as the fee recipient for transaction fees proposed validators in Prysm. This address will be receiving the fees of all proposer activity
- The go-ethereum JSON-RPC API is available at http://geth:8545
- The Prysm client's REST APIs are available at http://beacon-chain:3500. For more info on what these APIs are, see [here](https://ethereum.github.io/beacon-APIs/)
- The Prysm client also exposes a gRPC API at http://beacon-chain:4000
