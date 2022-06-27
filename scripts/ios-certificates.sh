#!/bin/sh
# this script helps you to deploy your certificates p12 and mobile provisioning file right on the agents

KEYCHAIN_NAME=$1
KEYCHAIN_PASSWORD=$2
CERTIFICATE_PASSWORD=$3
CERTIFICATE_PATH=$4
MOBILEPROVISIONNING_PATH=$5

echo "*** Unlocking the keychain..."
security unlock-keychain -p $KEYCHAIN_PASSWORD $HOME/Library/Keychains/$KEYCHAIN_NAME
echo  "*** import certificates..."
security import $CERTIFICATE_PATH -k $HOME/Library/Keychains/$KEYCHAIN_NAME -P $CERTIFICATE_PASSWORD -T /usr/bin/codesign
echo "*** import mobile provisionning profiles..."   
uuid=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i $MOBILEPROVISIONNING_PATH 2> /dev/null)_`
cp $MOBILEPROVISIONNING_PATH ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision
security set-key-partition-list -S apple-tool:,apple: -s -k $KEYCHAIN_PASSWORD $KEYCHAIN_NAME 1>/dev/null
