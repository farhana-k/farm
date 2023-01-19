#!/bin/bash
cd $FABRIC_CFG_PATH
# cryptogen generate --config crypto-config.yaml --output keyfiles
configtxgen -profile OrdererGenesis -outputBlock genesis.block -channelID systemchannel

configtxgen -printOrg buyer-agro-com > JoinRequest_buyer-agro-com.json
configtxgen -printOrg farmer-agro-com > JoinRequest_farmer-agro-com.json
