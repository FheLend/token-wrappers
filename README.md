# Tokens Wrapper

Implement FHERC20 tokens for testing token with localfhenix support.

## Quick start

The first things you need to do are cloning this repository and installing its dependencies:

```sh
git clone https://github.com/fhelend/token-wrappers.git
cd token-wrappers
pnpm install
```

Next, you need an .env file containing your mnemonics or keys. You can use .env.example that comes with a predefined mnemonic, or use your own

```sh
cp .env.example .env
```

Once the file exists, let's run a LocalFhenix instance:

```sh
pnpm localfhenix:start
```

This will start a LocalFhenix instance in a docker container. If this worked you should see a `Started LocalFhenix successfully` message in your console.

If not, please make sure you have `docker` installed and running on your machine. You can find instructions on how to install docker [here](https://docs.docker.com/get-docker/).

Now that we have a LocalFhenix instance running, we can deploy our contracts to it:

```sh
npx hardhat deploy
```

Note that this template defaults to use the `localfhenix` network, which is injected into the hardhat configuration.
## Hardhat Network

This template contains experimental support for testing using Hardhat Network. By importing the `fhenix-hardhat-network` plugin in `hardhat.config.ts` we add support for simulated operations using Hardhat Network. These do not perform the full FHE computations, and are menant to serve as development tools to verify contract logic.

Note that in order to use the hardhat network in tasks with `--network hardhat` the tasks need to deploy the contract themselves, as the network is ephemeral. Alternatively you can use the stand-alone hardhat network by setting it as the default network in `hardhat.config.ts`.

If you have any issues or feature requests regarding this support please open a ticket in this repository 

## Troubleshooting

If Localfhenix doesn't start this could indicate an error with docker. Please verify that docker is running correctly using the `docker run hello-world` command, which should run a basic container and verify that everything is plugged in.

For example, if the docker service is installed but not running, it might indicate you need to need to start it manually.