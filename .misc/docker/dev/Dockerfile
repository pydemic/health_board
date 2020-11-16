FROM node:15.0.1 AS node
FROM elixir:1.10.4

COPY --from=node /usr/local /usr/local
COPY --from=node /opt /opt

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
      git \
      inotify-tools \
      zip \
      && \
    apt-get clean && \
    mix local.hex --force && \
    mix local.rebar --force

CMD ["sleep", "infinity"]
