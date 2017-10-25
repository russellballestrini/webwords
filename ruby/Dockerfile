# origin: http://blog.kontena.io/building-minimal-docker-image-for-rails/
FROM alpine:latest

EXPOSE 8888

RUN apk update && apk --update add ruby ruby-irb ruby-json ruby-rake ruby-bigdecimal ruby-io-console ruby-rdoc

ADD config.ru /app/  
ADD Gemfile /app/

RUN apk --update add --virtual build-dependencies build-base ruby-dev \ 
    postgresql-dev libc-dev linux-headers ca-certificates libxml2-dev libxslt-dev \
    && gem install rails tzinfo-data \
    && apk del build-dependencies \
    && rm -rf /var/cache/apk/*

ADD . /app  
#RUN chown -R nobody:nogroup /app  
#USER nobody

ENV RAILS_ENV production  
WORKDIR /app

CMD ["rackup", "-p", "8888", "-o", "0.0.0.0"]  
