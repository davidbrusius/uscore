FROM elixir:1.14.3-alpine

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY . ./

RUN mix deps.get && mix deps.compile

EXPOSE 4000

CMD ["mix", "phx.server"]
