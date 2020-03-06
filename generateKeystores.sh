#!/bin/bash
## Script to generate  Keystores from existing Keys and Signed Certificates
##Build a host.txt file with all the FQDNs 
## e.g.  kafka-1.bodybygriz.dontexist.com. NOTE:  Zookeeper does not support TLS as of 5.1.2 so don't inlcude these hosts in the file
HOSTS_FILE=./hosts.txt
#CHange the extension for your files type, pem, cer, crt
CERT_EXT=.pem
KEY_EXT=.key
STORE_EXT=.jks
#NOTE YOU can't use a different password for the key in a PKCS12 formatted Keystore
PASSWORD=`cat passphrase.txt`

#Build the truststore once since this will be the same for all hosts if intermediates add separate keytool lines since it won't import multiple 
keytool -import -alias rootca -trustcacerts -file bodybygriz-ONSLAUGHT-CA.pem -keystore client.truststore.jks -storepass $PASSWORD -noprompt
#keytool -import -alias intermediateca -trustcacerts -file bodybygriz-ONSLAUGHT-InterCA.pem -keystore client.truststore.jks -storepass $PASSWORD -noprompt


cat $HOSTS_FILE | while read line
do
	line=`echo $line | cut -f1 -d "~"`
	echo $line$CERT_EXT
	#First combine trust chain you don't have a bundle
	#cat intermediate.pem bodybygriz-ONSLAUGHT-CA.pem > $line-CA$CERT_EXT
	#Note:  Passout would not work with file:  Error: Error reading password from BIO.  Did not research since I found a workaround
	openssl pkcs12 -export -in $line$CERT_EXT -inkey $line$KEY_EXT -passin file:passphrase.txt -chain -CAfile bodybygriz-ONSLAUGHT-CA.pem -certfile $line$CERT_EXT -name "$line" -out $line.p12 -passout pass:$PASSWORD
	keytool -importkeystore -srckeystore $line.p12 -srcstoretype pkcs12 -srcstorepass $PASSWORD -destkeystore $line$STORE_EXT -deststorepass $PASSWORD -deststoretype PKCS12
done
