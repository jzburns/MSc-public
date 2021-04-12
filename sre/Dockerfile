FROM golang:latest

WORKDIR /app

COPY httpServer_crash.go ./
COPY index.html ./
COPY error.html ./
# COPY restart.sh ./
RUN go build httpServer_crash.go

EXPOSE 8080

CMD ["./httpServer_crash"]
