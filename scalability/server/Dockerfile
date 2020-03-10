FROM golang:latest

WORKDIR /app

COPY httpServer.go ./
COPY index.html ./

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]
