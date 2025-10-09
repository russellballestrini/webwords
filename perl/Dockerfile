FROM perl:5.36

RUN cpanm HTTP::Daemon HTTP::Status LWP::UserAgent URI::Escape URL::Encode LWP::Protocol::https

WORKDIR /app
COPY app.pl .
RUN chmod +x app.pl

EXPOSE 31337

CMD ["./app.pl"]