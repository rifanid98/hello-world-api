# Hello World API

Simple Golang REST API menggunakan [Echo](https://echo.labstack.com/) framework.

## Requirements

- Go 1.21+

## Installation

```bash
go mod tidy
```

## Running

```bash
# Via Makefile
make run

# Atau langsung
go run ./cmd/api/main.go
```

Server akan berjalan di `http://localhost:8080`

## Endpoints

| Method | Path     | Description        |
|--------|----------|--------------------|
| GET    | `/hello` | Returns hello world |

### Example Request

```bash
curl http://localhost:8080/hello
```

### Example Response

```json
{
  "message": "hello world"
}
```

## Project Structure

```
hello-world-api/
├── cmd/
│   └── api/
│       └── main.go              # Entry point
├── internal/
│   └── handler/
│       └── hello.go             # Hello handler
├── go.mod
├── go.sum
├── Makefile
└── README.md
```
