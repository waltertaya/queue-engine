FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o queue-engine ./cmd/main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/queue-engine .
EXPOSE 50051
CMD ["./queue-engine"]
