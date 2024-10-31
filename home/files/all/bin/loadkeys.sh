#!/bin/sh

# add all encrypted keys from keychain
# disabled because order is important. ~/.ssh/id_rsa has to go first otherwise
# it might cause problems with git auth. Also heldenzeit sshd setup will reject
# a second attempt.
#ssh-add --apple-load-keychain

# personal general key. Add this one first because all servers have set MaxAuthTries=1
# for security reasons. If this key is not offered first then auth will fail
# This was disabled because I use openssl ssh-add
#ssh-add --apple-use-keychain ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
ssh-add ~/keys/arq2024
ssh-add ~/keys/db/steinert.id_rsa


### T-Systems CH Keys
# general
#ssh-add --apple-use-keychain ~/keys/tsch/ssteine2.id_rsa
# vcloud linux systems
#ssh-add --apple-use-keychain ~/keys/tsch/tsch-appl_rsa
# Legacy keys
#ssh-add --apple-use-keychain ~/keys/tsch/cacti_id_rsa
# splunk 2017 systems
#ssh-add --apple-use-keychain ~/keys/tsch/splunk-new_rsa
# splunk otc systems
#ssh-add --apple-use-keychain ~/keys/tsch/splunk-otc.id_rsa

### Netlution / SAP
#ssh-add --apple-use-keychain ~/keys/netlution/cgs
#ssh-add --apple-use-keychain ~/keys/netlution/admansible
#ssh-add --apple-use-keychain ~/keys/netlution/666ansible
#ssh-add --apple-use-keychain ~/keys/netlution/c01ansible
#ssh-add --apple-use-keychain ~/keys/netlution/777ansible
#ssh-add --apple-use-keychain ~/keys/netlution/888ansible
#ssh-add --apple-use-keychain ~/keys/netlution/stefan

### German Edge Cloud GEC
#ssh-add --apple-use-keychain ~/keys/gec/stefan_ed25519
#ssh-add --apple-use-keychain ~/keys/gec/observability

echo "List of active keys:"
ssh-add -l
