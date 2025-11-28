#!/bin/bash -e

# set -x (bash debug) if log level is trace
log-helper level eq trace && set -x

# Reduce maximum number of number of open file descriptors to 1024
# otherwise slapd consumes two orders of magnitude more of RAM
# see https://github.com/docker/docker/issues/8231
ulimit -n $LDAP_NOFILE

# Call hostname to determine the fully qualified domain name. We want OpenLDAP to listen
# to the named host for the ldap:// and ldaps:// protocols.
if [ -z "$FQDN" ]; then
  # Only call hostname if the fully qualified domain name wasn't provided as environment variable.
  FQDN="$(/bin/hostname --fqdn)"
fi
HOST_PARAM="ldap://$FQDN:$LDAP_PORT ldaps://$FQDN:$LDAPS_PORT"
exec /usr/sbin/slapd -h "$HOST_PARAM ldapi:///" -u openldap -g openldap -d "$LDAP_LOG_LEVEL"
