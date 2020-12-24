FROM elixir:1.11.2-alpine

RUN mix local.hex --force \
  && mix local.rebar --force \
  && apk --no-cache --update add postgresql-client bash alpine-sdk coreutils curl \
  && rm -rf /var/cache/apk/* \
  && mkdir /app

COPY . /app
WORKDIR /app

RUN mix deps.get

EXPOSE 4000
