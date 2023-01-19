#!/bin/bash
# Script to instantiate chaincode
cp $FABRIC_CFG_PATH/core.yaml /vars/core.yaml
cd /vars
export FABRIC_CFG_PATH=/vars

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=10.0.2.15:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/farmer.agro.com/peers/peer1.farmer.agro.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=farmer-agro-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/farmer.agro.com/users/Admin@farmer.agro.com/msp
export ORDERER_ADDRESS=10.0.2.15:7006
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/agro.com/orderers/orderer1.agro.com/tls/ca.crt

# 1. Fetch the channel configuration
peer channel fetch config config_block.pb -o $ORDERER_ADDRESS \
  --cafile $ORDERER_TLS_CA --tls -c agrochannel

# 2. Translate the configuration into json format
configtxlator proto_decode --input config_block.pb --type common.Block \
  | jq .data.data[0].payload.data.config > agrochannel_current_config.json
echo "--<<-->>--"

# 3. Update the current config in json with the organization anchor peer we want to add
jq '.channel_group.groups.Application.groups."farmer-agro-com".values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "10.0.2.15","port": 7002}]},"version": "0"}}' agrochannel_current_config.json > agrochannel_modified_anchor_config.json

# 4. Translate the current config in json format to protobuf format
configtxlator proto_encode --input agrochannel_current_config.json \
  --type common.Config --output config.pb

# 5. Translate the desired config in json format to protobuf format
configtxlator proto_encode --input agrochannel_modified_anchor_config.json \
  --type common.Config --output modified_config.pb

# 6. Calculate the delta of the current config and desired config
configtxlator compute_update --channel_id agrochannel \
  --original config.pb --updated modified_config.pb \
  --output agrochannel_anchor_update.pb

# 7. Decode the delta of the config to json format
configtxlator proto_decode --input agrochannel_anchor_update.pb \
  --type common.ConfigUpdate | jq . > agrochannel_anchor_update.json

# 8. Now wrap of the delta config to fabric envelop block
echo '{"payload":{"header":{"channel_header":{"channel_id":"agrochannel", "type":2}},"data":{"config_update":'$(cat agrochannel_anchor_update.json)'}}}' | jq . > agrochannel_anchor_update_envelope.json

# 9. Encode the json format into protobuf format
configtxlator proto_encode --input agrochannel_anchor_update_envelope.json \
  --type common.Envelope --output agrochannel_anchor_update_envelope.pb

# 10. Need to sign anchor update envelop by org admin
peer channel update -o $ORDERER_ADDRESS --tls --cafile $ORDERER_TLS_CA \
  -f agrochannel_anchor_update_envelope.pb -c agrochannel
