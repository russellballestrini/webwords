FROM elixir:1.14-alpine

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app
COPY mix.exs ./
RUN mix deps.get
RUN mix deps.compile

COPY lib ./lib
RUN mix compile

EXPOSE 31337

CMD ["mix", "run", "--no-halt"]