FROM golang:latest

WORKDIR /app

COPY httpServerBanking.go ./
COPY index.html ./
COPY error.html ./
RUN go build httpServerBanking.go

EXPOSE 80

CMD ["./httpServerBanking"]
