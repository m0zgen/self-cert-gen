#!/bin/bash

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

SERVER_NAME=`hostname`

## SSL Config
country=XX
state=Earth
locality=World
organization=$SERVER_NAME
organizationalunit=$SERVER_NAME
email=root@$SERVER_NAME
days=365

function installSelfSignedNginxSSL() {

	# Generate SSL and config
	mkdir -p /etc/nginx/ssl

	openssl req -x509 -nodes -days $days -newkey rsa:4096 \
	-keyout $SCRIPT_PATH/nginx-selfsigned.key -out $SCRIPT_PATH/nginx-selfsigned.crt \
	-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$SERVER_NAME/emailAddress=$email"

}

installSelfSignedNginxSSL