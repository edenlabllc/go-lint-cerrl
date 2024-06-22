#!/usr/bin/env bash

cd /app

go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.59.1

go build --buildmode plugin -o /tmp/cerrl.so plugin/cerrl.go

cat config/.golangci.yml | sed "s/path: ..\/cerrl.so/path: \/tmp\/cerrl.so/g" > /tmp/.golangci.yml

golangci-lint run -v --config /tmp/.golangci.yml

rm /tmp/cerrl.so