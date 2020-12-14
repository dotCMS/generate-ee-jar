# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
# dotCMS core distributed under GPLv3 license (https://github.com/dotCMS/core/blob/master/license.txt)
FROM openjdk:8-jdk-alpine as dotcms-ee

LABEL com.dotcms.contact "info@dotcms.com"
LABEL com.dotcms.vendor "dotCMS LLC"
LABEL com.dotcms.description "dotCMS Content Management System"
LABEL com.github.actions.icon "hash"
LABEL com.github.actions.color "gray-dark"

WORKDIR /srv

# Build env dependencies
RUN apk update \
    && apk --no-cache upgrade \
    && apk add --no-cache bash openssh openssl libc6-compat curl gnupg grep sed tini nss s6-dns git nodejs=10.19.0-r0 npm=10.19.0-r0

COPY entrypoint.sh /entrypoint.sh
RUN chmod 500 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
