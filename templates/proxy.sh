#!/bin/sh

tee -a "$HOME/proxy-do.sh" >/dev/null <<EOF
#!/bin/sh

if [ "\$TERM_PROGRAM" = "Apple_Terminal" ]; then
    sudo -k security add-trusted-cert -d -p ssl -p basic -k /Library/Keychains/System.keychain "/Volumes/My Shared Files/devbox/credentials-mitm-proxy-container/ca.crt"
    ## sudo -k security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "/Volumes/My Shared Files/devbox/credentials-mitm-proxy-container/ca.crt"
fi

#export CA_CRT="/Volumes/My Shared Files/devbox/credentials-mitm-proxy-container/ca.crt"
#export SSL_CERT_FILE=\$CA_CRT
#export SSL_CERT_FILE="\$(brew --prefix)/etc/ca-certificates/cert.pem"
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > "\$HOME/mac-ca-bundle.pem"
security find-certificate -a -p /Library/Keychains/System.keychain >> "\$HOME/mac-ca-bundle.pem"
export SSL_CERT_FILE="\$HOME/mac-ca-bundle.pem"

#export CA_CRT_X="/Volumes/My Shared Files/devbox/credentials-mitm-proxy-container/ca.crt"
#export NODE_EXTRA_CA_CERTS=\$CA_CRT_X
export NODE_EXTRA_CA_CERTS="\$HOME/mac-ca-bundle.pem"

export NODE_USE_ENV_PROXY=1

export NODE_OPTIONS="--use-openssl-ca"
# --use-system-ca NODE_TLS_REJECT_UNAUTHORIZED=0

export HTTP_PROXY="http://nono:xxx@127.0.0.1:10255"
export HTTPS_PROXY="http://nono:xxx@127.0.0.1:10255"
export NO_PROXY="localhost,127.0.0.1,192.168.65.0/24,192.168.64.0/24"
EOF

tee -a "$HOME/proxy-undo.sh" >/dev/null <<EOF
#!/bin/sh

unset HTTP_PROXY
unset HTTPS_PROXY
unset NO_PROXY
unset CA_CRT
unset SSL_CERT_FILE
unset CA_CRT_X
unset NODE_EXTRA_CA_CERTS
unset NODE_USE_ENV_PROXY
unset NODE_OPTIONS

if [ "\$TERM_PROGRAM" = "Apple_Terminal" ]; then
    sudo -k security remove-trusted-cert -d "/Volumes/My Shared Files/devbox/credentials-mitm-proxy-container/ca.crt"
fi
EOF
