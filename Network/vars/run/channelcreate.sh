#!/bin/bash
# Script to create channel block 0 and then create channel
cp $FABRIC_CFG_PATH/core.yaml /vars/core.yaml
cd /vars
export FABRIC_CFG_PATH=/vars
configtxgen -profile OrgChannel \
  -outputCreateChannelTx agrochannel.tx -channelID agrochannel

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=10.0.2.15:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/farmer.agro.com/peers/peer1.farmer.agro.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=farmer-agro-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/farmer.agro.com/users/Admin@farmer.agro.com/msp
export ORDERER_ADDRESS=10.0.2.15:7008
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/agro.com/orderers/orderer3.agro.com/tls/ca.crt
peer channel create -c agrochannel -f agrochannel.tx -o $ORDERER_ADDRESS \
  --cafile $ORDERER_TLS_CA --tls
