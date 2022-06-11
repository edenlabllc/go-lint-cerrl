build-plugin:
	go build --buildmode plugin -o plugin/bin/golangci-lint-cerrl.so plugin/cerrl.go

install:
	go install ./cmd/...

run:
	go run cmd/cerrl/main.go ./...

vet:
	go vet -vettool=$(which cerrl) ./...

test:
	go test -v ./...

lint:
	golangci-lint run -v
