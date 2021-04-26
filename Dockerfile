# syntax = docker/dockerfile:1.2

# Build process is based on alpine image
FROM --platform=${BUILDPLATFORM} golang:1.16-alpine AS base
WORKDIR /app


# Define a general gobuilder image
FROM base AS gobuilder
WORKDIR /app/src
ENV CGO_ENABLED=0
RUN --mount=type=bind,target=/app/src,source=src,readwrite \
    go mod download


# Define a build image
FROM gobuilder AS gobuild


# Define a unit-test image
FROM gobuilder AS unit-test


# Define a lint image
FROM gobuilder AS lint
RUN go get -u golang.org/x/lint/golint


# Define a godoc generator and serve image
# This one get's an update to godoc from
# out golang-tools stable-featured repo
FROM gobuilder AS godoc
RUN go get golang.org/x/tools/cmd/godoc
RUN apk add git && \
    cd /tmp && \
    git clone -b stable-featured https://github.com/TomFreudenberg/golang-tools.git && \
    cd golang-tools && \
    go build -o /go/bin/godoc golang.org/x/tools/cmd/godoc


