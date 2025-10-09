FROM mcr.microsoft.com/powershell:latest

WORKDIR /app
COPY webwords.ps1 .

# Execution policy not needed in Linux containers

EXPOSE 31337

CMD ["pwsh", "-ExecutionPolicy", "Bypass", "-File", "./webwords.ps1"]