#!/bin/sh

# add all encrypted keys from keychain
# disabled because order is important. ~/.ssh/id_rsa has to go first otherwise
# it might cause problems with git auth. Also heldenzeit sshd setup will reject
# a second attempt.
#ssh-add --apple-load-keychain

# personal general key. Add this one first because all servers have set MaxAuthTries=1
# for security reasons. If this key is not offered first then auth will fail.
# Disabled because I use openssl ssh-add
#ssh-add --apple-use-keychain ~/.ssh/id_rsa
# 2024-11-01 Use Apple again
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_rsa
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/arq2024
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/db/steinert.id_rsa


### T-Systems CH Keys
# general
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/tsch/ssteine2.id_rsa
# vcloud linux systems
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/tsch/tsch-appl_rsa
# Legacy keys
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/tsch/cacti_id_rsa
# splunk 2017 systems
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/tsch/splunk-new_rsa
# splunk otc systems
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/tsch/splunk-otc.id_rsa

### Netlution / SAP
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/netlution/cgs
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/netlution/admansible
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/netlution/666ansible
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/netlution/c01ansible
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/netlution/777ansible
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/netlution/888ansible
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/netlution/stefan

### German Edge Cloud GEC
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/gec/stefan_ed25519
#/usr/bin/ssh-add --apple-use-keychain ~/.ssh/gec/observability

echo "List of active keys:"
/usr/bin/ssh-add -l
