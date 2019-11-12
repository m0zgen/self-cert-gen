#!/bin/bash

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Vars
# ---------------------------------------------------\
SERVER_NAME=`hostname`

# Sel-SSL Conf
country=XX
state=Earth
locality=World
organization=$SERVER_NAME
organizationalunit=$SERVER_NAME
email=root@localhost

function eoff() {

cat > $SCRIPT_PATH/ssl.conf <<_EOF_
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

# Generate certificate
function installSelfSignedNginxSSL() {

  # Create ssl folder  
  mkdir -p /etc/nginx/ssl/
  eoff
  # Gen
  openssl req -x509 -newkey rsa:4096 -days 365 -keyout $SCRIPT_PATH/self-key.pem -nodes -out $SCRIPT_PATH/self-request.csr -config $SCRIPT_PATH/ssl.conf

}

# Invoke generator
installSelfSignedNginxSSL
