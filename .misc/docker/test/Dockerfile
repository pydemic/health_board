FROM node:15.0.1 AS node
FROM elixir:1.10.4

ENV MIX_ENV=test

COPY --from=node /usr/local /usr/local
COPY --from=node /opt /opt

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
      git \
      inotify-tools \
      && \
    apt-get clean && \
    mix local.hex --force && \
    mix local.rebar --force

COPY assets/package.json assets/yarn.lock assets/
COPY config config
COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile && \
    yarn install --cwd assets

CMD ["mix", "test.ci"]
