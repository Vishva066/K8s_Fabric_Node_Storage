export CHANNEL_NAME=autochannel

# CORE_PEER_LOCALMSPID=MvdMSP

CORE_PEER_MSPCONFIGPATH=/organizations/peerOrganizations/mvd.auto.com/users/Admin@mvd.auto.com/msp

peer channel join -b /channel-artifacts/${CHANNEL_NAME}.block

peer channel list