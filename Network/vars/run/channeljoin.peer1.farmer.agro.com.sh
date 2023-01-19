#!/bin/bash
# Script to join a peer to a channel
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=10.0.2.15:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/farmer.agro.com/peers/peer1.farmer.agro.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=farmer-agro-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/farmer.agro.com/users/Admin@farmer.agro.com/msp
export ORDERER_ADDRESS=10.0.2.15:7007
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/agro.com/orderers/orderer2.agro.com/tls/ca.crt
if [ ! -f "agrochannel.genesis.block" ]; then
  peer channel fetch oldest -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA \
  --tls -c agrochannel /vars/agrochannel.genesis.block
fi

peer channel join -b /vars/agrochannel.genesis.block \
  -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA --tls
