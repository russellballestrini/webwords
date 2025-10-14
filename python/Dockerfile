FROM python:3.13-alpine

ENTRYPOINT ["/bin/webwords"]

EXPOSE 31337

COPY requirements.txt /tmp/requirements.txt
COPY main.py /bin/webwords

RUN chmod 0754 /bin/webwords

RUN apk --no-cache add ca-certificates \
    && pip3 install -r /tmp/requirements.txt \
    && rm -rf /var/cache/apk/*
