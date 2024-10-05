export CHANNEL_NAME=autochannel
CORE_PEER_LOCALMSPID=$1

peer channel join -b /channel-artifacts/${CHANNEL_NAME}.block

peer channel list