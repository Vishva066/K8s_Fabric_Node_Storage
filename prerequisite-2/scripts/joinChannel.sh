export CHANNEL_NAME=autochannel

# CORE_PEER_LOCALMSPID=DealerMSP

CORE_PEER_MSPCONFIGPATH=/organizations/peerOrganizations/dealer.auto.com/users/Admin@dealer.auto.com/msp

peer channel join -b /channel-artifacts/${CHANNEL_NAME}.block

peer channel list