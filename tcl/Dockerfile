FROM alpine:latest

# Install TCL packages (tcl includes basic HTTP support)
RUN apk add --no-cache tcl ca-certificates curl

WORKDIR /app
COPY webwords.tcl .
RUN chmod +x webwords.tcl

EXPOSE 31337

CMD ["./webwords.tcl"]