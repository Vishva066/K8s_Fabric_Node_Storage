#  Orderer 3

mkdir -p organizations/ordererOrganizations/auto.com

export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/auto.com
echo $FABRIC_CA_CLIENT_HOME

set -x
fabric-ca-client enroll -u https://admin:adminpw@ca-orderer:10054 --caname ca-orderer --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem
{ set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >/organizations/ordererOrganizations/auto.com/msp/config.yaml

echo "Register orderer3"
set -x
fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles  /organizations/fabric-ca/ordererOrg/tls-cert.pem
{ set +x; } 2>/dev/null

mkdir -p organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com

echo "Generate the orderer3 msp"
set -x
fabric-ca-client enroll -u https://orderer:ordererpw@ca-orderer:10054 --caname ca-orderer -M /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/msp --csr.hosts orderer3.auto.com --csr.hosts localhost --csr.hosts ca-orderer --csr.hosts orderer3 --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem
{ set +x; } 2>/dev/null

cp /organizations/ordererOrganizations/auto.com/msp/config.yaml /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/msp/config.yaml

echo "Generate the orderer3-tls certificates"
set -x
fabric-ca-client enroll -u https://orderer:ordererpw@ca-orderer:10054 --caname ca-orderer -M /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls --enrollment.profile tls --csr.hosts orderer3.auto.com --csr.hosts localhost --csr.hosts ca-orderer3 --csr.hosts orderer3 --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem
{ set +x; } 2>/dev/null

cp /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/tlscacerts/* /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/ca.crt
cp /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/signcerts/* /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/server.crt
cp /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/keystore/* /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/server.key

mkdir -p /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/msp/tlscacerts
cp /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/tlscacerts/* /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem

mkdir -p /organizations/ordererOrganizations/auto.com/msp/tlscacerts
cp /organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/tls/tlscacerts/* /organizations/ordererOrganizations/auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem
