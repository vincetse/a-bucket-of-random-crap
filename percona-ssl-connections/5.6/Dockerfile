FROM percona:5.6

USER root
RUN \
  yum install -y \
    openssl && \
  yum clean all
COPY ssl.cnf /etc/my.cnf.d/
COPY mysql56-generate-ssl-certs.sh /docker-entrypoint-initdb.d/

USER mysql
