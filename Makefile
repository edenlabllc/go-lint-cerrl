build-plugin:
	go build --buildmode plugin plugin/cerrl.go

install:
	go install ./cmd/...

run:
	go run cmd/cerrl/main.go ./...

vet:
	go vet -vettool=$(shell which cerrl) ./...

test:
	go test -v ./...

lint:
	golangci-lint run -v --timeout 10m -c config/.golangci.yml

lint-no-plugin:
	golangci-lint run -v --timeout 10m -c config/.golangci-no-plugin.yml

lint-plugin-only:
	golangci-lint run -v --timeout 10m -c config/.golangci-plugin-only.yml

lint-docker:
	docker-compose -f docker/docker-compose-lint.yaml up
