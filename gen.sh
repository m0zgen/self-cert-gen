#!/bin/bash

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)


# Variables
SERVER_NAME=`hostname`
CERTS_CATALOG=$SCRIPT_PATH/certs
mkdir -p $CERTS_CATALOG

# SSL Variables Section

# Single line config section
# (generateCertFromLine)
country=XX
state=Earth
locality=World
organization=$SERVER_NAME
organizationalunit=$SERVER_NAME
email=root@$SERVER_NAME
days=365

# Custom config section
# (generateCertFromConfig)
function eoff() {
cat > $CERTS_CATALOG/ssl.conf <<_EOF_
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
[req_distinguished_name]
C = ${country}
ST = ${state}
L = ${locality}
O = ${SERVER_NAME}
OU = ${SERVER_NAME}
CN = www.${SERVER_NAME}
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.${SERVER_NAME}
DNS.2 = ${SERVER_NAME}
_EOF_

}

# Functions

# Help information
usage() {

	echo -e "\nArguments:
	-l (Single line config section. Default.)
	-c (Custom config section)
	-m (monit.pem generator)
	-t (Deploy generated config to custom target catalog)\n"
	exit 1

}

# Checks arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--line) _LINE=1; ;;
		-c|--config) _CONFIG=1; ;;
		-m|--monit) _MONIT=1; ;;
		-t|--target) _DIR=1 _TARGET="$2"; shift ;;
		-h|--help) usage ;;	
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Generate certificate from Conf
function generateCertFromConfig() {

	echo -e "Certs will be created in $CERTS_CATALOG: self-key.pem / self-request.csr :\n"

	eoff
	openssl req -x509 -newkey rsa:4096 -days $days -keyout $CERTS_CATALOG/self-key.pem -nodes -out $CERTS_CATALOG/self-request.csr -config $CERTS_CATALOG/ssl.conf
	ls -l $CERTS_CATALOG
}

# Single line generator
function generateCertFromLine() {

	echo -e "Certs will be created in $CERTS_CATALOG: nginx-selfsigned.crt / nginx-selfsigned.key :\n"

	openssl req -x509 -nodes -days $days -newkey rsa:4096 \
	-keyout $CERTS_CATALOG/nginx-selfsigned.key -out $CERTS_CATALOG/nginx-selfsigned.crt \
	-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$SERVER_NAME/emailAddress=$email"
	ls -l $CERTS_CATALOG
}

# Monit pem generator
# https://mmonit.com/wiki/Monit/EnableSSLInMonit
function generateMonitPem() {

	eoff
	openssl req -new -x509 -days $days -nodes \
    -config $CERTS_CATALOG/ssl.conf -out $CERTS_CATALOG/monit.pem \
    -keyout $CERTS_CATALOG/monit.pem

	openssl dhparam -2 2048 >> $CERTS_CATALOG/monit.pem
	chmod 600  $CERTS_CATALOG/monit.pem
	
	echo -e "
monit.pem located in $CERTS_CATALOG/monit.pem
	
you can copy monit.pem to /etc/monit/certs/ with command:\n
cp $CERTS_CATALOG/monit.pem /etc/monit/certs/monit.pem

	Example monit SSL config:

	    SET HTTPD PORT 2812
	      WITH SSL {
	        PEMFILE: /etc/ssl/certs/monit.pem
	        SELFSIGNED: ALLOW
	    }
"
}

# Cerate catalog if needed
function createCatalog() {

	if [[ ! -d "$_TARGET" ]]; then
		echo "Create target: $_TARGET"
		mkdir -p $_TARGET
	else
		echo "Target already exist"
	fi

}

# Target catalog from -t option
function createTarget() {

	if [[ -z "$_TARGET" ]]; then
		echo "Target not defined, please copy certificates manually."
	else
		createCatalog
	fi
	
}

# Options
if [[ "$_LINE" -eq "1" ]]; then
	
	generateCertFromLine

	if [[ "$_DIR" -eq "1" ]]; then
		createTarget
	fi

elif [[ "$_CONFIG" -eq "1" ]]; then
	
	generateCertFromConfig

	if [[ "$_DIR" -eq "1" ]]; then
		createTarget
	fi
elif [[ "$_MONIT" -eq "1" ]]; then
	
	generateMonitPem

	if [[ "$_DIR" -eq "1" ]]; then
		createTarget
	fi
else
	usage
	exit 1
fi



