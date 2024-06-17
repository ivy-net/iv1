# Ethereum Proof-of-Stake Devnet with deployment of the EigenLayer contracts

## Introduction

This repository is a fork of the [POS DevNet](https://github.com/ivy-net/eth-pos-devnet) repository, extended by an automatic deployment of the EigenLayer contracts.
There a few scenarios with different level of deployment automation (e.g. only EigenLayer smart contracts, above plus smart contracts for the Increadible Squaring AVS, the whole AVS).
To see how it can be use to deploy an AVS check the [Quick Start](#quick-start) section.

## Components

### Docker compose
There are multile docker-compose configuration files located in subfolders of the `docker-compose` folder.
The first one, in the `docker-compose/eigenlayer` subfolder, deploys the POS network with the EigenLayer contracts only.
The second one, in the `docker-compose/incredible-squaring-avs` subfolder, adds the demo AVS to the network, but uses the older version of the EigenLayer.
It is because this AVS does not work the latest EigenLayer code.
Additionally, in the `docker-compose/incredible-squaring-avs-full` subfolder there is scenario deploying all AVS components (inclugin off-chain programs and monitoring tools).

#### Extending scenarios library
Please do not hesitate to add another docker-compose scenario, especially if you are an AVS developer.

### Packer
There is the packer script to prepare and upload iv1 images to ECR.
The images based on forge one and contains the source code with built smart contracts of the EigenLayer (EL) and the Incredible Squaring AVS (IS) projects.

### Other folders
Other folders contain information specific for the chain (`consensus` and `execution`) or deployed smart contracts (`eigenlayer` and `incredible-squaring-avs`).

## Quick Start

To deploy the POS network with EigenLayer and Incredible Squaring AVS contracts follow these steps:
* Clean previous deployments
```
./clean.sh
```
* Navigate to the folder with docker compose definition for the IS AVS:
```
cd docker-compose/incredible-squaring-avs
```
* Start Docker Compose:
```
docker-compose up -d
```
* Check logs of the eigenlayer, avs-demo and cast containers to confirm that all the contracts have been deployed successfully and ether has been transferred:
```
docker-compose logs eigenlayer
docker-compose logs avs-demo
docker-compose logs cast
```
* Download the source code of the incredible-squaring-avs (to run the off-chain components):
```
cd ../../../
git clone https://github.com/ivy-net/incredible-squaring-avs.git
```
* Copy configuration files specific for the POS chain to the `config-files` folder in the Incredible Squaring AVS.
The files are located in the incredible-squaring-avs/32382 subfolder of the iv1 repository.
```
cp -r  iv1/incredible-squaring-avs/32382 incredible-squaring-avs/config-files
```
* Additionally, the output of the AVS smart contracts deployment needs to be copied:
```
mkdir -p incredible-squaring-avs/contracts/script/output/32382/
cp iv1/eigenlayer/incredible.json incredible-squaring-avs/contracts/script/output/32382/credible_squaring_avs_deployment_output.json
```
* With the files copied over, off-chain component of the AVS can be started with the following commands.
Please note, that they have to be run in the main folder of the AVS project.
```
cd incredible-squaring-avs
```
* Start Aggregator with:
```
make CHAINID=32382 start-aggregator
```
* and Operator (by running following command in the new terminal):
```
make CHAINID=32382 start-operator
```

The logs should appear in both terminals.
Some of the tasks might not be validate properly, because of a timing issue.
This problem is unique to the POS network.

At the end, stop docker:
```
cd ../iv1/docker-compose/incredible-squaring-avs
docker-compose -f docker-compose.yml down
```

## Other scenarios

### Deploy EigenLayer only

To deploy POS network only with EigenLayer contracts follow these steps:
```
./clean.sh
cd docker-compose/eignelayer
docker-compose up -d
```
Check logs of the eigenlayer container to confirm that all the contracts have been deployed successfully:
```
docker-compose logs eigenlayer
```

### Deploy Incredible Squaring AVS

The iv1 might be used to deploy the IS AVS from the local machine, rather than from a docker image.

First follow steps from the [deploy the EigenLayer](#deploy-eigenlayer-only) section.

_NOTE: the IS AVS might not work with latest EL code.
In such case adjust the docker-compose and replace the image from the `iv1-eigenlayer` to the `iv1-is-avs`.


#### Download code and copy configuration

*WORK IN PROGRESS*

To code of the Incredible Squaring AVS is require to continue.
It can be found in the Ivy-Net fork [Incredible Squaring AVS](https://github.com/ivy-net/incredible-squaring-avs/tree/master).
(_The fork is required only for the one commit, which has been approved, but not yet merged.
The change allows to use the CHAINID other than the 31337._)

```
cd ../../../
git clone https://github.com/ivy-net/incredible-squaring-avs.git
```
If the incredible-squaring-avs folder is present, ensure that git configuration points at code from the ivy-net repository.

* Copy configuration files specific for the POS chain to the `config-files` folder in the Incredible Squaring AVS.
The files are located in the incredible-squaring-avs/32382 subfolder of the iv1 repository.
```
cp -r  iv1/incredible-squaring-avs/32382 incredible-squaring-avs/config-files
```
* Additionally, the output of the AVS smart contracts deployment needs to be copied:
```
mkdir -p incredible-squaring-avs/contracts/script/output/32382/
cp iv1/eigenlayer/output.json incredible-squaring-avs/contracts/script/output/32382/eigenlayer_deployment_output.json
```

#### Deploy smart contracts
* Navigate to the _contracts_ folder of the Incredible Squaring AVS.
```
cd incredible-squaring-avs/contracts
```
* Build smart contracts
```
forge build
```
* Upload smart contracts into the blockchain
```
forge script script/IncredibleSquaringDeployer.s.sol \
 --rpc-url http://localhost:8545 \
 --broadcast \
 --unlocked \
 --sender 0x123463a4b065722e99115d6c222f267d9cabb524
```
* Navigate to the main folder of the AVS to start off-chain components of it.
```
cd ../
```
* The next step is to top up the operator account. To do this run following command:
```
cast send 0x860B6912C2d0337ef05bbC89b0C2CB6CbAEAB4A5 --value 10ether --private-key 0x2e0834786285daccd064ca17f1654f67b4aef298acbb82cef9ec422fb4975622
```
or use the make command:
```
make \
  DEPLOYER_PRIVATE_KEY=0x2e0834786285daccd064ca17f1654f67b4aef298acbb82cef9ec422fb4975622 \
  CHAINID=32382 \
  send-fund
```

#### Run off-chain components
* Start Aggregator with:
```
make CHAINID=32382 start-aggregator
```
* and Operator (by running following command in the new terminal):
```
make CHAINID=32382 start-operator
```

#### Finish
* When finish remember to stop docker-compose deployment
```
cd ../iv1/docker-compose/incredible-squaring-avs
docker-compose down
```

### Full Incredible Squaring AVS deployment

In this scenario deployment of all components is automate.

#### Deployment
* Navigate to the scenario subfolder
```
cd docker-compose/incredible-squaring-avs-full
```
* Run docker compose
```
docker-compose up -d
```
* Check smart contracts deployment logs
```
docker-compose logs eigenlayer
docker-compose logs avs-demo
docker-compose logs cast
```
* Follow off-chain program logs
```
docker-compose logs -f aggregator operator
```

#### Monitoring

* In the web browser navigate to the port 3000 on the localhost (http://localhost:3000)
* Use default Grafana credentials:
```
user: admin
pass: admin
```
* In the left hand side menu select _Dashboards_
* Select _AVSs_ section in the main panel
* Click onto the _Incredible Squaring_ link
* Additionally, the promethus dashboard is avaliable at the port 9090 (https://localhost:9090)

# Build process

*WORK IN PROGRESS*

## Packer

* Ensure that you have docker and packer installed and docker daemon is running.
* Adjust the _docker-tag_ step and comment out the _docker-push_ in the _post_processors_ sections to avoid attempt to login to  the ivy-net ECR.
We left commented out lines for local deployment.
* Build the images with packer
```
cd packer
packer init .
packer build -var 'version=1.1' .
```
* If the repository is changed to the local one, adjust image name in the relevant docker-compose.yml file as well.

_NOTE: The process might take 10--15 minutes, depends on hardware._

There will be 2 images prepared:
* iv1-eigenlayer - contains the latest dev build of EigenLayer contracts
* iv1-is-avs - contains the above and Incredible Squaring AVS pre-build contracts

_NOTE: If you experience hangs in the compilation or build process, update docker to the latest version._

## Docker image to deploy EigenLayer

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
It is to give time for the blockchain to settle, before publishing the EL contracts.
Additionally, the insecure http connections are permitted from the remote hosts.
This change enables forge (from the foundry image) to deployed the code.

Finally, docker image version was locked for in a few cases, because of issues with the software.
The smart contracts cannot be deployed with geth 1.14, because of (https://github.com/ethereum/go-ethereum/issues/29898).
Prysmctl does not have stable release and recently introduce settings for the next fork which breaks the chain deployment.


# Original Ethereum Proof-of-Stake Devnet

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
