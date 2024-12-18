#!/usr/bin/env bash

cd /app

go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.62.2

go build --buildmode plugin -o /tmp/cerrl.so plugin/cerrl.go

cat config/.golangci.yml | sed "s/path: ..\/cerrl.so/path: \/tmp\/cerrl.so/g" > /tmp/.golangci.yml

# To get the version of a specific library
golangci-lint version --debug | grep "golang.org/x/tools"

golangci-lint run -v --config /tmp/.golangci.yml

rm /tmp/cerrl.so
