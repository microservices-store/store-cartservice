FROM microsoft/dotnet:2.1-sdk-alpine as builder
WORKDIR /app
COPY . .
RUN dotnet restore && \
    dotnet build && \
    dotnet publish -c release -r linux-musl-x64 -o /cartservice

# cartservice
FROM alpine:3.8
ARG REPO_NAME
ARG COMMIT_SHA
ARG SHORT_SHA
ARG PROJECT_ID
ARG BUILD_ID
ARG BRANCH_NAME
ARG TAG_NAME
ARG REVISION_ID
ARG BLDDATE

LABEL REPO_NAME=$REPO_NAME \
    COMMIT_SHA=$COMMIT_SHA \
    SHORT_SHA=$SHORT_SHA \
    PROJECT_ID=$PROJECT_ID \
    BUILD_ID=$BUILD_ID \
    BRANCH_NAME=$BRANCH_NAME \
    TAG_NAME=$TAG_NAME \
    REVISION_ID=$REVISION_ID \
    BLDDATE=$BLDDATE

RUN GRPC_HEALTH_PROBE_VERSION=v0.2.0 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

# Dependencies for runtime
# busybox-extras => telnet
RUN apk add --no-cache \
    busybox-extras \
    libc6-compat \
    libunwind \
    libuuid \
    libgcc \
    libstdc++ \
    libintl \
    icu
WORKDIR /app
COPY --from=builder /cartservice .
ENTRYPOINT ["./cartservice", "start"]
