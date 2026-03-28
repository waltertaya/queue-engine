# Queue Engine

A gRPC-based queue service built with Go and PostgreSQL (Supabase).

## Architecture

```
Node.js / Python Client
     ↓ gRPC (TLS)
Queue Engine (Go) — railway.app
     ↓
PostgreSQL (Supabase)
```

## Deliverables

### Phase 1 — gRPC Skeleton
- [x] `queue.proto` — service contract defined
- [x] gRPC code generated (`proto/queue.pb.go`, `proto/queue_grpc.pb.go`)
- [x] Go server running on port `50051`
- [x] `JoinQueue` endpoint responding
- [x] `GetPosition` endpoint defined

### Phase 2 — Real Queue Logic
- [x] Connect to Supabase (PostgreSQL)
- [x] Implement transaction-safe `JoinQueue`
- [x] Implement `GetPosition` with live DB query

### Phase 3 — Production Hardening
- [ ] Error handling & input validation
- [x] Dockerize the service
- [x] Environment config via `.env`
- [x] Deploy on Railway

## gRPC Endpoints

| Method        | Input                 | Output                            |
|---------------|-----------------------|-----------------------------------|
| `JoinQueue`   | `user_id`, `queue_id` | `ticket_id`, `position`, `status` |
| `GetPosition` | `user_id`, `queue_id` | `position`                        |

## Usage

### Node.js

**Install dependencies:**
```bash
npm install @grpc/grpc-js @grpc/proto-loader
```

**Client:**
```javascript
const grpc = require("@grpc/grpc-js");
const protoLoader = require("@grpc/proto-loader");

const packageDef = protoLoader.loadSync("queue.proto");
const proto = grpc.loadPackageDefinition(packageDef).queue;

const client = new proto.QueueService(
  "queue-engine-production.up.railway.app:443",
  grpc.credentials.createSsl()
);

// Join a queue
client.JoinQueue({ user_id: "user-123", queue_id: "queue-abc" }, (err, response) => {
  if (err) return console.error(err);
  console.log("ticket_id:", response.ticket_id);
  console.log("position :", response.position);
  console.log("status   :", response.status);
});

// Get position
client.GetPosition({ user_id: "user-123", queue_id: "queue-abc" }, (err, response) => {
  if (err) return console.error(err);
  console.log("position:", response.position);
});
```

---

### Python

**Install dependencies:**
```bash
pip install grpcio grpcio-tools
```

**Generate client code from proto:**
```bash
python -m grpc_tools.protoc -I./proto --python_out=. --grpc_python_out=. ./proto/queue.proto
```

**Client:**
```python
import grpc
import queue_pb2
import queue_pb2_grpc

credentials = grpc.ssl_channel_credentials()
channel = grpc.secure_channel("queue-engine-production.up.railway.app:443", credentials)
stub = queue_pb2_grpc.QueueServiceStub(channel)

# Join a queue
response = stub.JoinQueue(queue_pb2.JoinQueueRequest(
    user_id="user-123",
    queue_id="queue-abc"
))
print("ticket_id:", response.ticket_id)
print("position :", response.position)
print("status   :", response.status)

# Get position
response = stub.GetPosition(queue_pb2.GetPositionRequest(
    user_id="user-123",
    queue_id="queue-abc"
))
print("position:", response.position)
```

## Local Development

```bash
# Copy env
cp .env.example .env

# Generate gRPC code
protoc --go_out=. --go-grpc_out=. proto/queue.proto

# Run server
go run cmd/main.go
```

Server starts on `localhost:50051`.

## Environment Variables

| Variable      | Description                 |
|---------------|-----------------------------|
| `GRPC_PORT`   | Port to run the gRPC server |
| `DB_HOST`     | Supabase pooler host        |
| `DB_PORT`     | Database port (5432)        |
| `DB_NAME`     | Database name               |
| `DB_USER`     | Database user               |
| `DB_PASSWORD` | Database password           |
| `DB_SSL_MODE` | SSL mode (require)          |

## Tech Stack

- **Language:** Go
- **Transport:** gRPC / Protocol Buffers
- **Database:** PostgreSQL via Supabase
- **Hosting:** Railway
