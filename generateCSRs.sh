#!/bin/bash

HOSTS_FILE=hosts.txt
CSRCONF_FILE=./csrreq.conf

cat $HOSTS_FILE | while read line
do
	echo "##################################################"
	echo "##################################################"
	## Grab short name in case you need it for SAN
	SHORT_NAME=${line%%.*}
	echo "short name:                     $SHORT_NAME"
	CN_NAME_STRING=`echo $line | cut -s -d "~" -f1`
	echo "cn Name:                         $CN_NAME_STRING"
	SUBJECT=$(<subject.txt)/CN=${CN_NAME_STRING}
	echo "Subj: $SUBJECT"
        
	DNS_NAMES_STRING=`echo $line | cut -s -d "~" -f2`
	echo "Before if:                       $DNS_NAMES_STRING"
	if [ -z "$DNS_NAMES_STRING" ];
	then
		CN_NAME_STRING=`echo $line`
		DNS_NAMES_STRING=`echo DNS:$line`
	else
		DNS_NAMES_STRING=`echo DNS:$CN_NAME_STRING,$DNS_NAMES_STRING`
	fi
        echo "After IF: $CN_NAME_STRING"
        echo "After IF: $DNS_NAMES_STRING"

	## Key first
	openssl genrsa -aes128 -passout file:passphrase.txt -out $CN_NAME_STRING.key 4096
	#Then CSR
	## you have to add Subj Alt Name (SAN) with the FQDN due to something going on in the new versions of Java and Browser
	openssl req -new -sha256 -key $CN_NAME_STRING.key -passin file:passphrase.txt -out $CN_NAME_STRING.csr -subj "$SUBJECT" -reqexts SAN -config <(cat $CSRCONF_FILE <(printf "\n[SAN]\nsubjectAltName=$DNS_NAMES_STRING"))
done

