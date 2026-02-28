# =============================================================================
# Stage 1: Builder
# =============================================================================
FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /app

# Cache dependencies
COPY go.mod go.sum ./
RUN go mod download && go mod verify

# Copy source
COPY . .

# Build binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o /app/server \
    ./cmd/api

# =============================================================================
# Stage 2: Runtime
# =============================================================================
FROM alpine:3.19

RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/server .
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["./server"]
