ARG GO_VERSION=1
FROM golang:${GO_VERSION}-bookworm as builder

WORKDIR /usr/src/app
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY . .
RUN go build -v -o /run-app .

# --- Stage สุดท้าย (Runtime) ---
FROM debian:bookworm

# 1. เพิ่มบรรทัดนี้เพื่อติดตั้ง curl และ certificates
RUN apt-get update && apt-get install -y curl ca-certificates

# 2. ติดตั้ง flyctl
RUN curl -L https://fly.io/install.sh | sh

# 3. ตั้งค่า PATH ให้เรียกใช้ fly ได้เลย
ENV FLYCTL_INSTALL="/root/.fly"
ENV PATH="$FLYCTL_INSTALL/bin:$PATH"

COPY --from=builder /run-app /usr/local/bin/
CMD ["run-app"]