
export FABRIC_CFG_PATH=${PWD}/configtx

export CHANNEL_NAME=autochannel

# configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block

configtxgen -profile ThreeOrgsChannel -channelID $CHANNEL_NAME -outputBlock /channel-artifacts/${CHANNEL_NAME}.block