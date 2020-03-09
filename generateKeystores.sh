#!/bin/bash
## Script to generate  Keystores from existing Keys and Signed Certificates

HOSTS_FILE=./hosts.txt
ROOTCA=bodybygriz-ONSLAUGHT-CA.pem 
INTERMEDIATE=bodybygriz-ONSLAUGHT-InterCA.pem 

#Change the extension for your files type, pem, cer, crt
CERT_EXT=.pem
KEY_EXT=.key
STORE_EXT=.jks

#NOTE YOU can't use a different password for the key in a PKCS12 formatted Keystore
PASSWORD=`cat passphrase.txt`

# Build the truststore once since this will be the same for all hosts
# if intermediates add separate keytool lines since it won't import multiple 

keytool -import -alias rootca -trustcacerts -file $ROOTCA -keystore client.truststore.jks -storepass $PASSWORD -noprompt
#keytool -import -alias intermediateca -trustcacerts -file $INTERMEDIATE -keystore client.truststore.jks -storepass $PASSWORD -noprompt

cat $HOSTS_FILE | while read line
do
	line=`echo $line | cut -f1 -d "~"`
	echo $line$CERT_EXT

	#First combine trust chain you don't have a bundle
	#cat intermediate.pem bodybygriz-ONSLAUGHT-CA.pem > $line-CA$CERT_EXT

	openssl pkcs12 -export -in $line$CERT_EXT -inkey $line$KEY_EXT \
		-passin file:passphrase.txt -chain \
		-CAfile $ROOTCA -certfile $line$CERT_EXT \
		-name "$line" -out $line.p12 \
		-passout pass:$PASSWORD
	keytool -importkeystore \
		-srckeystore $line.p12 -srcstoretype pkcs12 -srcstorepass $PASSWORD \
		-destkeystore $line$STORE_EXT -deststorepass $PASSWORD -deststoretype PKCS12
done
