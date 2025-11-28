# OpenLDAP Docker Image
# Based on Debian Trixie with OpenLDAP 2.6.x
FROM debian:trixie-slim

ARG LDAP_OPENLDAP_GID
ARG LDAP_OPENLDAP_UID

# Add openldap user and group first to make sure their IDs get assigned consistently
# If explicit uid or gid is given, use it.
RUN if [ -z "${LDAP_OPENLDAP_GID}" ]; then groupadd -g 911 -r openldap; else groupadd -r -g ${LDAP_OPENLDAP_GID} openldap; fi \
    && if [ -z "${LDAP_OPENLDAP_UID}" ]; then useradd -u 911 -r -g openldap openldap; else useradd -r -g openldap -u ${LDAP_OPENLDAP_UID} openldap; fi

# Install OpenLDAP and required packages
RUN echo "path-include /usr/share/doc/krb5*" >> /etc/dpkg/dpkg.cfg.d/docker \
    && apt-get -y update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    ldap-utils \
    libsasl2-modules \
    libsasl2-modules-db \
    libsasl2-modules-gssapi-mit \
    libsasl2-modules-ldap \
    libsasl2-modules-otp \
    libsasl2-modules-sql \
    openssl \
    slapd \
    slapd-contrib \
    krb5-kdc-ldap \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /var/lib/ldap/* /etc/ldap/slapd.d/*

# Create directory structure
RUN mkdir -p /container/service/slapd/assets \
    && mkdir -p /container/environment/99-default \
    && mkdir -p /container/state \
    && mkdir -p /container/tool \
    && mkdir -p /var/run/slapd \
    && chown openldap:openldap /var/run/slapd

# Add helper tools
ADD tool /container/tool
RUN chmod +x /container/tool/*

# Add service directory to /container/service
ADD service /container/service

# Make scripts executable
RUN chmod +x /container/service/slapd/*.sh

# Add default env variables
ADD environment /container/environment/99-default

# Expose default ldap and ldaps ports
EXPOSE 389 636

# Set environment variables
ENV CONTAINER_SERVICE_DIR=/container/service \
    CONTAINER_STATE_DIR=/container/state

# Entrypoint
ENTRYPOINT ["/container/tool/run"]

# Put ldap config and database dir in a volume to persist data.
# VOLUME /etc/ldap/slapd.d /var/lib/ldap
