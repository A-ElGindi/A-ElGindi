FROM golang:1.16.4

LABEL maintainer "student@mcgill.ca"
LABEL gowebapp "v1"

EXPOSE 80

ENV GO111MODULE=auto
ENV GOPATH=/go

COPY /code $GOPATH/src/gowebapp/

WORKDIR $GOPATH/src/gowebapp/

RUN go get && go install

ENTRYPOINT $GOPATH/bin/gowebapp
