#
# docker build -t europe-west2-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/unreliable-banking-sre/latest .
# docker push europe-west2-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/unreliable-banking-sre/latest
#
FROM golang:latest

WORKDIR /app

COPY httpServer_crash.go ./
COPY index.html ./
COPY error.html ./
RUN go build httpServer_crash.go

EXPOSE 8080

CMD ["./httpServer_crash"]
