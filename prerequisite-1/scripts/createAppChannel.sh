export CHANNEL_NAME=autochannel

export ORDERER_CA=${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem

export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/server.crt

export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/server.key


# peer channel create -o orderer:7050 -c autochannel -f ./channel-artifacts/autochannel.tx --outputBlock ./channel-artifacts/autochannel.block --tls --cafile /organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem

osnadmin channel join --channelID $CHANNEL_NAME --config-block ${PWD}/channel-artifacts/$CHANNEL_NAME.block -o orderer:7051 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY

osnadmin channel list -o orderer:7051 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY

