.PHONY: run tidy build

## run: Start the API server
run:
	go run ./cmd/api/main.go

## build: Build the binary
build:
	go build -o bin/api ./cmd/api/main.go

## tidy: Tidy go modules
tidy:
	go mod tidy
