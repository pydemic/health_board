FROM elixir:1.10.4-alpine

ENV MIX_ENV=prod \
    HB__ENDPOINT__SECRET_KEY_BASE=changeme

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

RUN apk add --update git build-base nodejs yarn

COPY assets/package.json assets/yarn.lock assets/
COPY config config
COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile && \
    yarn install --cwd assets

COPY assets assets

RUN cd assets && \
    yarn run deploy

COPY lib lib
COPY priv priv

RUN mix phx.digest && \
    mix compile && \
    mix release health_board
