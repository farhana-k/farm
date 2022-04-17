#!/bin/bash
# Script to join a peer to a channel
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=10.0.2.15:7005
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/buyer.agro.com/peers/peer1.buyer.agro.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=buyer-agro-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/buyer.agro.com/users/Admin@buyer.agro.com/msp
export ORDERER_ADDRESS=10.0.2.15:7011
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/agro.com/orderers/orderer3.agro.com/tls/ca.crt
if [ ! -f "agrochannel.genesis.block" ]; then
  peer channel fetch oldest -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA \
  --tls -c agrochannel /vars/agrochannel.genesis.block
fi

peer channel join -b /vars/agrochannel.genesis.block \
  -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA --tls
