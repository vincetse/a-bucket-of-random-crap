FROM gliderlabs/herokuish AS builder
ENV NPM_CONFIG_PRODUCTION false
RUN /usr/bin/git clone https://github.com/vincetse/pixeld /tmp/app
RUN /bin/herokuish buildpack build


FROM heroku/heroku:18
RUN useradd -m heroku
WORKDIR /app
RUN chown heroku:heroku .
COPY --chown=heroku:heroku --from=builder /app .
USER heroku
RUN \
  mkdir -p .fly && \
  echo "npm run start" > .fly/boot.sh && \
  chmod +x .fly/boot.sh
ENV HOME /app
ENV PORT 8080
CMD ["/bin/bash", "-c", "for f in /app/.profile.d/*.sh; do source $f; done && /app/.fly/boot.sh"]
