FROM golang:alpine AS build
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
WORKDIR /go/bin
RUN apk add --no-cache git
RUN go get -d -v github.com/adnanh/webhook
RUN go build --ldflags '-s -extldflags "-static"' -i -o webhook github.com/adnanh/webhook

FROM alpine
RUN apk add --no-cache bash coreutils curl jq
COPY --from=build /go/bin/webhook /usr/local/bin/
COPY hooks.json /etc/webhook/
WORKDIR /etc/webhook
VOLUME /etc/webhook
EXPOSE 9000
ENTRYPOINT ["webhook"]
CMD ["-hooks", "hooks.json", "-hotreload", "-template", "-verbose"]