#!/bin/sh
# Use socat to proxy git through an HTTP CONNECT firewall.
# Useful if you are trying to clone git:// from inside a company.
# Requires that the proxy allows CONNECT to port $_PROXYPORT
#
# Save this file as gitproxy somewhere in your path (e.g., ~/bin) and then run
#   chmod +x gitproxy
#   git config --global core.gitproxy gitproxy
#
# More details at https://www.emilsit.net/blog/archives/how-to-use-the-git-protocol-through-a-http-connect-proxy/

# Configuration. Common proxy ports are 3128, 8123, 8000, 8080.
_PROXY=proxy.t-systems.ch
_PROXYPORT=8080

exec socat STDIO PROXY:$_PROXY:$1:$2,proxyport=$_PROXYPORT
