FROM debian:jessie

ENV DOVECOT_VERSION 2.2.21
ENV DOVECOT_TGZ_URL http://dovecot.org/releases/2.2/dovecot-$DOVECOT_VERSION.tar.gz
ENV DOVECOT_GNUPG_KEY 40558AC9

RUN installDeps='libsqlite3-0 libldap-2.4-2 libpam0g libexpat1 libssl1.0.0 libpq5 libmysqlclient18' \
    && buildDeps='wget build-essential libsqlite3-dev libldap2-dev libpam0g-dev libexpat1-dev libssl-dev libpq-dev libmysqlclient-dev' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $installDeps $buildDeps \
    && mkdir /usr/src/dovecot \
    && cd /usr/src/dovecot \
    && wget $DOVECOT_TGZ_URL $DOVECOT_TGZ_URL.sig \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $DOVECOT_GNUPG_KEY \
    && gpg --verify dovecot-$DOVECOT_VERSION.tar.gz.sig \
    && tar -xvf dovecot-$DOVECOT_VERSION.tar.gz --strip-components=1 \
    && ./configure \
        --sysconfdir=/etc \
        --with-solr \
        --with-pgsql --with-mysql --with-sqlite \
        --with-shadow --with-pam --with-nss \
        --with-sql --with-ldap \
    && make -j"$(nproc)" \
    && make install \
    && cd / \
    && rm -r /usr/src/dovecot \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && groupadd -r dovecot \
    && groupadd -r dovenull \
    && useradd -r -M -d /nonexistant -g dovecot -s /bin/false dovecot \
    && useradd -r -M -d /nonexistant -g dovenull -s /bin/false dovenull

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
EXPOSE 110 143 993 995
