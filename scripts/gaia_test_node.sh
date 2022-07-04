#!/bin/bash
rm -rf $HOME/.gaia/

MONIKER=test
CHAINID=gaia
KEYRING=test

#MONIKER : test, CHAINID : gaia
gaiad init $MONIKER --chain-id $CHAINID

gaiad config keyring-backend test

gaiad keys add genkey --recover
gaiad keys add relayer --recover
gaiad keys add bot --recover

gaiad add-genesis-account $(gaiad keys show genkey -a) 10000000000uatom
gaiad add-genesis-account $(gaiad keys show relayer -a) 10000000000uatom
gaiad add-genesis-account $(gaiad keys show bot -a) 10000000000uatom

gaiad gentx genkey 1000000000uatom --chain-id gaia

gaiad collect-gentxs

# update staking genesis
cat $HOME/.gaia/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json
cat $HOME/.gaia/config/genesis.json | jq '.app_state["staking"]["params"]["unbonding_time"]="600s"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json
cat $HOME/.gaia/config/genesis.json | jq '.app_state["staking"]["params"]["max_entries"]="1000000"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json

# update crisis variable to uatom
cat $HOME/.gaia/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json

# update mint denom
cat $HOME/.gaia/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json

# update liquidity denom
cat $HOME/.gaia/config/genesis.json | jq '.app_state["liquidity"]["params"]["pool_creation_fee"][0]["denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json

# udpate gov genesis
cat $HOME/.gaia/config/genesis.json | jq '.app_state["gov"]["voting_params"]["voting_period"]="120s"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json
cat $HOME/.gaia/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json

# upadate interchain-accounts genesis
cat $HOME/.gaia/config/genesis.json | jq '.app_state["interchainaccounts"]["host_genesis_state"]["params"]["allow_messages"]=["/cosmos.authz.v1beta1.MsgExec","/cosmos.authz.v1beta1.MsgGrant","/cosmos.authz.v1beta1.MsgRevoke","/cosmos.bank.v1beta1.MsgSend","/cosmos.bank.v1beta1.MsgMultiSend","/cosmos.distribution.v1beta1.MsgSetWithdrawAddress","/cosmos.distribution.v1beta1.MsgWithdrawValidatorCommission","/cosmos.distribution.v1beta1.MsgFundCommunityPool","/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward","/cosmos.feegrant.v1beta1.MsgGrantAllowance","/cosmos.feegrant.v1beta1.MsgRevokeAllowance","/cosmos.gov.v1beta1.MsgVoteWeighted","/cosmos.gov.v1beta1.MsgSubmitProposal","/cosmos.gov.v1beta1.MsgDeposit","/cosmos.gov.v1beta1.MsgVote","/cosmos.staking.v1beta1.MsgEditValidator","/cosmos.staking.v1beta1.MsgDelegate","/cosmos.staking.v1beta1.MsgUndelegate","/cosmos.staking.v1beta1.MsgBeginRedelegate","/cosmos.staking.v1beta1.MsgCreateValidator","/cosmos.vesting.v1beta1.MsgCreateVestingAccount","/ibc.applications.transfer.v1.MsgTransfer","/tendermint.liquidity.v1beta1.MsgCreatePool","/tendermint.liquidity.v1beta1.MsgSwapWithinBatch","/tendermint.liquidity.v1beta1.MsgDepositWithinBatch","/tendermint.liquidity.v1beta1.MsgWithdrawWithinBatch"]' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json


# change rpc ip address
sed -i -E 's|laddr = \"tcp://127.0.0.1:26657\"|laddr = \"tcp://0.0.0.0:26657\"|g' $HOME/.gaia/config/config.toml
sed -i -E 's|cors_allowed_origins = \[\]|cors_allowed_origins = \[\"*\"\]|g' $HOME/.gaia/config/config.toml

sed -i -E 's|minimum-gas-prices = \"\"|minimum-gas-prices = \"0uatom\"|g' $HOME/.gaia/config/app.toml

./build/gaiad start