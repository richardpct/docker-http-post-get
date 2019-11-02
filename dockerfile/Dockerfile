FROM golang:1.13.1-alpine

LABEL maintainer="richardpct"

RUN apk add --no-cache \
    git \
    curl \
    && go get github.com/richardpct/go-http-post-get

EXPOSE 8080

CMD ["/go/bin/go-http-post-get"]
