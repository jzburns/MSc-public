FROM golang:1.12.0-alpine3.9

WORKDIR /app

COPY httpServer.go ./
COPY index.html ./

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]
