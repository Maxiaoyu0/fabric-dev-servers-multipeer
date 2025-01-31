cd "$(dirname "$0")"

HOST1="52.174.98.196"
HOST2="13.93.0.148"
HOST3="13.94.231.130"


sed -i -e "s/{IP-HOST-1}/$HOST1/g" configtx.yaml
sed -i -e "s/{IP-HOST-1}/$HOST1/g" ../startFabric-Peer2.sh
sed -i -e "s/{IP-HOST-1}/$HOST1/g" ../startFabric-Peer3.sh
sed -i -e "s/{IP-HOST-2}/$HOST2/g" ../createPeerAdminCard.sh
sed -i -e "s/{IP-HOST-3}/$HOST3/g" ../createPeerAdminCard.sh

#cryptogen generate --config=./crypto-config.yaml
#export FABRIC_CFG_PATH=$PWD
#configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block
#configtxgen -profile ComposerChannel -outputCreateChannelTx ./composer-channel.tx -channelID composerchannel

ORG1KEY="$(ls crypto-config/peerOrganizations/org1.example.com/ca/ | grep 'sk$')"
ORG2KEY="$(ls crypto-config/peerOrganizations/org2.example.com/ca/ | grep 'sk$')"
ORG3KEY="$(ls crypto-config/peerOrganizations/org3.example.com/ca/ | grep 'sk$')"


sed -i -e "s/{ORG1-CA-KEY}/$ORG1KEY/g" docker-compose.yml
sed -i -e "s/{ORG2-CA-KEY}/$ORG2KEY/g" docker-compose-peer2.yml
sed -i -e "s/{ORG3-CA-KEY}/$ORG3KEY/g" docker-compose-peer3.yml

