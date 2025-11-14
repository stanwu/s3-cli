
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    make \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION=1.23.4

RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tgz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm /tmp/go.tgz

ENV PATH=/usr/local/go/bin:${PATH}
ENV GOPATH=/go
ENV GOBIN=/go/bin
ENV PATH=${GOBIN}:${PATH}

RUN mkdir -p /go /workspaces && chown -R vscode:vscode /go /workspaces

USER vscode
WORKDIR /workspaces

RUN go version || true
