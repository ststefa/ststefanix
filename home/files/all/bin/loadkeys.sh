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
#ssh-add ~/.ssh/arq2024
ssh-add ~/.ssh/db/steinert.id_rsa


### T-Systems CH Keys
# general
#ssh-add --apple-use-keychain ~/.ssh/tsch/ssteine2.id_rsa
# vcloud linux systems
#ssh-add --apple-use-keychain ~/.ssh/tsch/tsch-appl_rsa
# Legacy keys
#ssh-add --apple-use-keychain ~/.ssh/tsch/cacti_id_rsa
# splunk 2017 systems
#ssh-add --apple-use-keychain ~/.ssh/tsch/splunk-new_rsa
# splunk otc systems
#ssh-add --apple-use-keychain ~/.ssh/tsch/splunk-otc.id_rsa

### Netlution / SAP
#ssh-add --apple-use-keychain ~/.ssh/netlution/cgs
#ssh-add --apple-use-keychain ~/.ssh/netlution/admansible
#ssh-add --apple-use-keychain ~/.ssh/netlution/666ansible
#ssh-add --apple-use-keychain ~/.ssh/netlution/c01ansible
#ssh-add --apple-use-keychain ~/.ssh/netlution/777ansible
#ssh-add --apple-use-keychain ~/.ssh/netlution/888ansible
#ssh-add --apple-use-keychain ~/.ssh/netlution/stefan

### German Edge Cloud GEC
#ssh-add --apple-use-keychain ~/.ssh/gec/stefan_ed25519
#ssh-add --apple-use-keychain ~/.ssh/gec/observability

echo "List of active keys:"
ssh-add -l
