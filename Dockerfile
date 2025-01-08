FROM golang:1.22.1-alpine as builder
RUN mkdir /app
WORKDIR /app

RUN apk add --no-cache make git gcc musl-dev

# This step is done separately than `COPY . /app/` in order to
# cache dependencies.
COPY go.mod go.sum Makefile /app/
RUN go mod download

COPY . /app/
RUN make build/docker

FROM alpine:3.21.2

LABEL repository="https://github.com/aevea/release-notary"
LABEL homepage="https://github.com/aevea/release-notary"
LABEL maintainer="Simon Prochazka <simon@fallion.net>"

LABEL com.github.actions.name="Release Notary Action"
LABEL com.github.actions.description="Create release notes"
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="blue"

RUN  apk add --no-cache --virtual=.run-deps ca-certificates git &&\
    mkdir /app

WORKDIR /app
COPY --from=builder /app/build/release-notary ./release-notary

RUN ln -s $PWD/release-notary /usr/local/bin

CMD ["release-notary"]
