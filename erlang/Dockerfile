FROM erlang:25-alpine as builder

WORKDIR /app
COPY rebar.config .
RUN rebar3 deps

COPY src ./src
RUN rebar3 release

FROM erlang:25-alpine
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/_build/default/rel/webwords /opt/webwords

EXPOSE 31337

CMD ["/opt/webwords/bin/webwords", "foreground"]