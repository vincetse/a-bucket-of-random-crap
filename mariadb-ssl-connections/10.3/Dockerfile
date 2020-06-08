FROM mariadb:10.3

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y -qq \
    openssl && \
  apt-get clean autoclean -y && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
  unset DEBIAN_FRONTEND
COPY ssl.cnf /etc/mysql/conf.d/
COPY generate-ssl-certs.sh /docker-entrypoint-initdb.d/
