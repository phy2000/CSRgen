# CERTgen
Scripts to generate TLS certificates

## Updates required:

* Copy `hosts.txt.example` to `hosts.txt` 
  * add your hosts and all SANS in the same format 
  
* Copy `passphrase.txt.example` to `passphrase.txt`
  * Change to the passphrase you will use for the private keys and keystore files

* Copy `subject.txt.example` to `subject.txt`
  * Edit the fields to fit your Subject fields.

## Generate the Certificate Signing Requests:

Once the files have been changed run `generateCSRs.sh` and it will create a `.csr` and `.key` file for each host entry.

## Verify the CSR files
You can verify the csr file with the following command
`openssl req -in <HOST>.csr -noout -text`

## Generate Keystores

You will need the Trust chain in individual Base64 Encoded `(pem)` files for the next step.

* Edit `generateKeystores.sh`

  * Add multiple lines to import the trust chain into the truststore.jks 

* Put the signed `.pem` files in the folder
* run  `generateKeystores.sh`
