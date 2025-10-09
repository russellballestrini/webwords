# origin: http://blog.kontena.io/building-minimal-docker-image-for-rails/
FROM ruby:3.4.6-alpine

EXPOSE 31337

RUN apk update && apk --update add build-base yaml-dev

ADD config.ru /app/  
ADD Gemfile /app/

RUN cd /app && bundle install --without development test

ADD . /app  
#RUN chown -R nobody:nogroup /app  
#USER nobody

ENV RAILS_ENV production  
WORKDIR /app

CMD ["sh", "-c", "rackup -p ${PORT:-31337} -o 0.0.0.0"]  
