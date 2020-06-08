FROM mysql:5.6

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
COPY mysql56-generate-ssl-certs.sh /docker-entrypoint-initdb.d/
