export CHANNEL_NAME=autochannel

export ORDERER_CA=/organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem

export ORDERER_ADMIN_TLS_SIGN_CERT=/organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/server.crt

export ORDERER_ADMIN_TLS_PRIVATE_KEY=/organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/server.key

osnadmin channel join --channelID $CHANNEL_NAME --config-block /channel-artifacts/$CHANNEL_NAME.block -o orderer3:7051 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY

osnadmin channel list -o orderer3:7051 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY
