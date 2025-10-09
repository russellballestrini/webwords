FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 31337

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["WebWords.fsproj", "."]
RUN dotnet restore "WebWords.fsproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "WebWords.fsproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "WebWords.fsproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebWords.dll"]