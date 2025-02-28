# Build the manager binary
FROM golang:1.19 as builder

WORKDIR /devops

COPY go.mod go.mod
COPY cmd/ cmd/

RUN go env -w GO111MODULE=on \
&& go env -w GOPROXY=https://goproxy.cn,direct \
&& go env -w CGO_ENABLED=0 \
&& go env -w GOOS=linux \
&& go mod tidy \
&& go build -a -o devops-go-sample cmd/main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM alpine:3.9
WORKDIR /devops
COPY --from=builder /devops/devops-go-sample .

EXPOSE 8080
ENTRYPOINT ["./devops-go-sample"]
