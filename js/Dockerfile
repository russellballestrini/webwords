FROM alpine:latest

# maybe use something like nexe to produce binary.
# https://github.com/nexe/nexe
#ENTRYPOINT ["/bin/webwords"]

EXPOSE 8888

COPY package.json /app/
COPY app.js /app/

#RUN chmod 0754 /bin/webwords
WORKDIR /app/

RUN apk --no-cache add nodejs nodejs-npm ca-certificates \
    && npm install \
    && rm -rf /var/cache/apk/*

CMD ["node", "app.js"]
