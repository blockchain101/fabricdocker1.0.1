#!/bin/bash

FABRIC_HOME=~/fabric1.0/src/github.com/hyperledger/fabric 
if [ -z "$1" ]; then
	echo "Setting channel to default name 'mychannel'"
	CHANNEL_NAME="mychannel"
else
        CHANNEL_NAME=$1
fi

echo "Setting channel to name $CHANNEL_NAME"
shift

if [ -z "$1" ]; then
	echo "Setting orgs profile to default name 'TwoOrgs'"
        ORGS_PROFILE=TwoOrgs
else
        ORGS_PROFILE=$1
fi

echo "Setting orgs profile to name $ORGS_PROFILE"
shift

if [ -z "$1" ]; then
        echo "Setting anchor peer orgs default value 'Org1 Org2'"
        ANCHOR_PEER_ORGS="Org1 Org2"
else
        ANCHOR_PEER_ORGS=$@
fi

echo "Setting anchor peer of orgs $ANCHOR_PEER_ORGS"

echo "Channel name - "$CHANNEL_NAME  "Organization profile - "$ORGS_PROFILE  "Anchor peer orgs - "$ANCHOR_PEER_ORGS
echo

#the configtx.yaml file for generating configurations
FABRIC_CFG_PATH=$PWD

echo "Generating genesis block using command:"
echo "$FABRIC_HOME/build/bin/configtxgen -profile ${ORGS_PROFILE}OrdererGenesis -outputBlock orderer-$ORGS_PROFILE.block"
$FABRIC_HOME/build/bin/configtxgen -profile ${ORGS_PROFILE}OrdererGenesis -outputBlock orderer-$ORGS_PROFILE.block

echo "Generating channel configuration transaction using command:"
echo "$FABRIC_HOME/build/bin/configtxgen -profile ${ORGS_PROFILE}Channel -outputCreateChannelTx channel-$ORGS_PROFILE-$CHANNEL_NAME.tx -channelID $CHANNEL_NAME"
$FABRIC_HOME/build/bin/configtxgen -profile ${ORGS_PROFILE}Channel -outputCreateChannelTx channel-$ORGS_PROFILE-$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

echo "Generating channel anchor peer orgs configuration update transactions using commands:"
for ANCHOR_PEER_ORG in $ANCHOR_PEER_ORGS; do
        echo "$FABRIC_HOME/build/bin/configtxgen -profile ${ORGS_PROFILE}Channel -outputAnchorPeersUpdate channel-$ORGS_PROFILE-$CHANNEL_NAME-anchor${ANCHOR_PEER_ORG}MSP.tx -channelID $CHANNEL_NAME -asOrg ${ANCHOR_PEER_ORG}MSP"
        $FABRIC_HOME/build/bin/configtxgen -profile ${ORGS_PROFILE}Channel -outputAnchorPeersUpdate channel-$ORGS_PROFILE-$CHANNEL_NAME-anchor${ANCHOR_PEER_ORG}MSP.tx -channelID $CHANNEL_NAME -asOrg ${ANCHOR_PEER_ORG}MSP
done
