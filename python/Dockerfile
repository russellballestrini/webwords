FROM alpine:latest

ENTRYPOINT ["/bin/webwords"]

EXPOSE 8888

COPY requirements.txt /tmp/requirements.txt
COPY main.py /bin/webwords

RUN chmod 0754 /bin/webwords

RUN apk --no-cache add python py-pip \
    && apk --no-cache add ca-certificates \
    && pip install -r /tmp/requirements.txt \
    && rm -rf /var/cache/apk/*
