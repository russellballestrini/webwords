FROM gcc:latest

RUN apt-get update && apt-get install -y \
    gfortran-14 \
    netcat-traditional \
    socat \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY webwords.f90 .
COPY webwords-http.sh .
COPY request-handler.sh .

# Compile Fortran program
RUN gfortran-14 -o webwords webwords.f90

# Make scripts executable
RUN chmod +x webwords-http.sh request-handler.sh

EXPOSE 31337

CMD ["./webwords-http.sh"]