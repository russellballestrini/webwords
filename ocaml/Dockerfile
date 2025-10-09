FROM ocaml/opam:alpine as builder

USER root
RUN apk add --no-cache ca-certificates gmp-dev openssl-dev pkgconfig

USER opam
WORKDIR /app
COPY --chown=opam:opam dune-project .
RUN opam install -y dune lwt cohttp-lwt-unix uri lwt_ssl

COPY --chown=opam:opam . .
RUN eval $(opam env) && dune build

FROM ocaml/opam:alpine
RUN sudo apk add --no-cache ca-certificates
COPY --from=builder /app/_build/install/default/bin/webwords /usr/local/bin/webwords

EXPOSE 31337

CMD ["webwords"]