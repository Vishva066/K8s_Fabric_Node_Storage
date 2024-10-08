export CHANNEL_NAME=autochannel

CORE_PEER_MSPCONFIGPATH=/organizations/peerOrganizations/manufacturer.auto.com/users/Admin@manufacturer.auto.com/msp

# CORE_PEER_LOCALMSPID=ManufacturerMSP

peer channel join -b /channel-artifacts/${CHANNEL_NAME}.block

peer channel list