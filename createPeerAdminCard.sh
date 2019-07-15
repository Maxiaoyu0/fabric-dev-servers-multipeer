#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Grab the file names of the keystore keys
ORG1KEY="$(ls composer/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/)"
ORG2KEY="$(ls composer/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/)"
ORG3KEY="$(ls composer/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp/keystore/)"

echo
# check that the composer command exists at a version >v0.14
if hash composer 2>/dev/null; then
    composer --version | awk -F. '{if ($2<15) exit 1}'
    if [ $? -eq 1 ]; then
        echo 'Sorry, Use createConnectionProfile for versions before v0.15.0' 
        exit 1
    else
        echo Using composer-cli at $(composer --version)
    fi
else
    echo 'Need to have composer-cli installed at v0.15 or greater'
    exit 1
fi
# need to get the certificate

cat << EOF > org1onlyconnection.json
{
    "name": "byfn-network-org1-only",
    "x-type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride" : "orderer.example.com"
        }
    ],
    "ca": {
        "url": "http://localhost:7054",
        "name": "ca.org1.example.com",
        "hostnameOverride": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "eventURL": "grpc://localhost:7053",
            "hostnameOverride": "peer0.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:8051",
            "eventURL": "grpc://localhost:8053",
            "hostnameOverride": "peer1.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:9051",
            "eventURL": "grpc://localhost:9053",
            "hostnameOverride": "peer2.org1.example.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}
EOF

cat << EOF > org1connection.json
{
    "name": "byfn-network-org1",
    "x-type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride" : "orderer.example.com"
        }
    ],
    "ca": {
        "url": "http://localhost:7054",
        "name": "ca.org1.example.com",
        "hostnameOverride": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "eventURL": "grpc://localhost:7053",
            "hostnameOverride": "peer0.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:8051",
            "eventURL": "grpc://localhost:8053",
            "hostnameOverride": "peer1.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:9051",
            "eventURL": "grpc://localhost:9053",
            "hostnameOverride": "peer2.org1.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:10051",
            "hostnameOverride": "peer0.org2.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:11051",
            "hostnameOverride": "peer1.org2.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:12051",
            "hostnameOverride": "peer2.org2.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:13051",
            "hostnameOverride": "peer0.org3.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:14051",
            "hostnameOverride": "peer1.org3.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:15051",
            "hostnameOverride": "peer2.org3.example.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}
EOF

PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/"${ORG1KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem

if composer card list -n @byfn-network-org1-only > /dev/null; then
    composer card delete -n @byfn-network-org1-only
fi

if composer card list -n @byfn-network-org1 > /dev/null; then
    composer card delete -n @byfn-network-org1
fi

composer card create -p org1onlyconnection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org1-only.card
composer card import --file /tmp/PeerAdmin@byfn-network-org1-only.card

composer card create -p org1connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org1.card
composer card import --file /tmp/PeerAdmin@byfn-network-org1.card

rm -rf org1onlyconnection.json

cat << EOF > org2onlyconnection.json
{
    "name": "byfn-network-org2-only",
    "x-type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride": "orderer.example.com"
        }
    ],
    "ca": {
        "url": "http://13.93.0.148:7054",
        "name": "ca.org2.example.com",
        "hostnameOverride": "ca.org2.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://13.93.0.148:10051",
            "eventURL": "grpc://13.93.0.148:10053",
            "hostnameOverride": "peer0.org2.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:11051",
            "eventURL": "grpc://13.93.0.148:11053",
            "hostnameOverride": "peer1.org2.example.com"

        }, {
            "requestURL": "grpc://13.93.0.148:12051",
            "eventURL": "grpc://13.93.0.148:12053",
            "hostnameOverride": "peer2.org2.example.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org2MSP",
    "timeout": 300
}
EOF

cat << EOF > org2connection.json
{
    "name": "byfn-network-org2",
    "x-type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride": "orderer.example.com"
        }
    ],
    "ca": {
        "url": "http://13.93.0.148:7054",
        "name": "ca.org2.example.com",
        "hostnameOverride": "ca.org2.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "hostnameOverride": "peer0.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:8051",
            "hostnameOverride": "peer1.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:9051",
            "hostnameOverride": "peer2.org1.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:10051",
            "eventURL": "grpc://13.93.0.148:10053",
            "hostnameOverride": "peer0.org2.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:11051",
            "eventURL": "grpc://13.93.0.148:11053",
            "hostnameOverride": "peer1.org2.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:12051",
            "eventURL": "grpc://13.93.0.148:12053",
            "hostnameOverride": "peer2.org2.example.com"
        },  {
            "requestURL": "grpc://13.94.231.130:13051",
            "eventURL": "grpc://13.94.231.130:13053",
            "hostnameOverride": "peer0.org3.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:14051",
            "eventURL": "grpc://13.94.231.130:14053",
            "hostnameOverride": "peer1.org3.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:15051",
            "eventURL": "grpc://13.94.231.130:15053",
            "hostnameOverride": "peer2.org3.example.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org2MSP",
    "timeout": 300
}
EOF

PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/"${ORG2KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem


if composer card list -n @byfn-network-org2-only > /dev/null; then
    composer card delete -n @byfn-network-org2-only
fi

if composer card list -n @byfn-network-org2 > /dev/null; then
    composer card delete -n @byfn-network-org2
fi

composer card create -p org2onlyconnection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org2-only.card
composer card import --file /tmp/PeerAdmin@byfn-network-org2-only.card

composer card create -p org2connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org2.card
composer card import --file /tmp/PeerAdmin@byfn-network-org2.card

rm -rf org2onlyconnection.json



cat << EOF > org3onlyconnection.json
{
    "name": "byfn-network-org3-only",
    "x-type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride": "orderer.example.com"
        }
    ],
    "ca": {
        "url": "http://13.94.231.130:7054",
        "name": "ca.org3.example.com",
        "hostnameOverride": "ca.org3.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://13.94.231.130:10051",
            "eventURL": "grpc://13.94.231.130:10053",
            "hostnameOverride": "peer0.org3.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:11051",
            "eventURL": "grpc://13.94.231.130:11053",
            "hostnameOverride": "peer1.org3.example.com"

        }, {
            "requestURL": "grpc://13.94.231.130:12051",
            "eventURL": "grpc://13.94.231.130:12053",
            "hostnameOverride": "peer2.org3.example.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "org3MSP",
    "timeout": 300
}
EOF

cat << EOF > org3connection.json
{
    "name": "byfn-network-org3",
    "x-type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride": "orderer.example.com"
        }
    ],
    "ca": {
        "url": "http://13.94.231.130:7054",
        "name": "ca.org3.example.com",
        "hostnameOverride": "ca.org3.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "hostnameOverride": "peer0.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:8051",
            "hostnameOverride": "peer1.org1.example.com"
        }, {
            "requestURL": "grpc://localhost:9051",
            "hostnameOverride": "peer2.org1.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:10051",
            "eventURL": "grpc://13.93.0.148:10053",
            "hostnameOverride": "peer0.org2.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:11051",
            "eventURL": "grpc://13.93.0.148:11053",
            "hostnameOverride": "peer1.org2.example.com"
        }, {
            "requestURL": "grpc://13.93.0.148:12051",
            "eventURL": "grpc://13.93.0.148:12053",
            "hostnameOverride": "peer2.org2.example.com"
        },  {
            "requestURL": "grpc://13.94.231.130:13051",
            "eventURL": "grpc://13.94.231.130:13053",
            "hostnameOverride": "peer0.org3.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:14051",
            "eventURL": "grpc://13.94.231.130:14053",
            "hostnameOverride": "peer1.org3.example.com"
        }, {
            "requestURL": "grpc://13.94.231.130:15051",
            "eventURL": "grpc://13.94.231.130:15053",
            "hostnameOverride": "peer2.org3.example.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org3MSP",
    "timeout": 300
}
EOF

PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp/keystore/"${ORG3KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp/signcerts/Admin@org3.example.com-cert.pem


if composer card list -n @byfn-network-org3-only > /dev/null; then
    composer card delete -n @byfn-network-org3-only
fi

if composer card list -n @byfn-network-org3 > /dev/null; then
    composer card delete -n @byfn-network-org3
fi

composer card create -p org3onlyconnection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org3-only.card
composer card import --file /tmp/PeerAdmin@byfn-network-org3-only.card

composer card create -p org3connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org3.card
composer card import --file /tmp/PeerAdmin@byfn-network-org3.card

rm -rf org3onlyconnection.json


echo "Hyperledger Composer PeerAdmin card has been imported"
composer card list

composer runtime install -c PeerAdmin@byfn-network-org1-only -n trade-network
composer runtime install -c PeerAdmin@byfn-network-org2-only -n trade-network
composer runtime install -c PeerAdmin@byfn-network-org3-only -n trade-network
composer identity request -c PeerAdmin@byfn-network-org1-only -u admin -s adminpw -d alice
composer identity request -c PeerAdmin@byfn-network-org2-only -u admin -s adminpw -d bob
composer identity request -c PeerAdmin@byfn-network-org3-only -u admin -s adminpw -d ma
composer network start -c PeerAdmin@byfn-network-org1 -a trade-network.bna -o endorsementPolicyFile=endorsement-policy.json -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem -A ma -C ma/admin-pub.pem
composer card create -p org1connection.json -u alice -n trade-network -c alice/admin-pub.pem -k alice/admin-priv.pem
composer card import -f alice@trade-network.card
composer card create -p org2connection.json -u bob -n trade-network -c bob/admin-pub.pem -k bob/admin-priv.pem
composer card import -f bob@trade-network.card
composer card create -p org3connection.json -u ma -n trade-network -c ma/admin-pub.pem -k ma/admin-priv.pem
composer card import -f ma@trade-network.card
