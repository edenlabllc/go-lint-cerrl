#!/usr/bin/env bash

cd /app

go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.62.2

echo "build..."
go build --buildmode plugin -o /tmp/cerrl.so plugin/cerrl.go

go version

cat config/.golangci.yml | sed "s/path: ..\/cerrl.so/path: \/tmp\/cerrl.so/g" > /tmp/.golangci.yml

ls -al /tmp

# To get all the information
golangci-lint version --debug

# To get the version of a specific library
golangci-lint version --debug | grep "golang.org/x/tools"

golangci-lint run -v --config /tmp/.golangci.yml

rm /tmp/cerrl.so