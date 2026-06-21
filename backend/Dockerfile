FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY Reactivities.sln ./
COPY API/API.csproj API/
COPY Application/Application.csproj Application/
COPY Domain/Domain.csproj Domain/
COPY Infrastructure/Infrastructure.csproj Infrastructure/
COPY Persistence/Persistence.csproj Persistence/

RUN dotnet restore

COPY . ./
RUN dotnet publish API/API.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

ARG APP_VERSION="1.0.0"
ARG COMMIT_SHA="unknown"
ARG BUILD_TIMESTAMP="unknown"
ARG IMAGE_DIGEST="unknown"
ARG SLSA_LEVEL="unknown"
ARG IMAGE_SIGNED="false"
ARG SBOM_ATTACHED="false"
ARG PROVENANCE_ATTACHED="false"

LABEL org.opencontainers.image.title="k8s-supply-chain" \
      org.opencontainers.image.description="Kubernetes Supply chain security" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.revision="${COMMIT_SHA}" \
      org.opencontainers.image.created="${BUILD_TIMESTAMP}" \
      org.opencontainers.image.source="https://github.com/davidlihor/k8s-supply-chain-security" \
      org.opencontainers.image.vendor="David Lihor"

ENV APP_VERSION=${APP_VERSION} \
    COMMIT_SHA=${COMMIT_SHA} \
    BUILD_TIMESTAMP=${BUILD_TIMESTAMP} \
    IMAGE_DIGEST=${IMAGE_DIGEST} \
    SLSA_LEVEL=${SLSA_LEVEL} \
    IMAGE_SIGNED=${IMAGE_SIGNED} \
    SBOM_ATTACHED=${SBOM_ATTACHED} \
    PROVENANCE_ATTACHED=${PROVENANCE_ATTACHED}

USER $APP_UID

EXPOSE 8080
ENTRYPOINT ["dotnet", "API.dll"]
