ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE} as build

WORKDIR /go/src/oracledb_exporter
COPY . .
RUN go get -d -v

ARG VERSION=0.5.1
ENV VERSION ${VERSION}

# Add the log level configuration
ENV LOG_LEVEL info,debug

RUN GOOS=linux GOARCH=amd64 go build -v -ldflags "-X main.Version=${VERSION} -s -w"

FROM ${BASE_IMAGE} as exporter

ENV VERSION=${VERSION}
ENV LOG_LEVEL=${LOG_LEVEL}
ENV DEBIAN_FRONTEND=noninteractive

ARG LEGACY_TABLESPACE
ENV LEGACY_TABLESPACE=${LEGACY_TABLESPACE}
COPY --from=build /go/src/oracledb_exporter/oracledb_exporter /oracledb_exporter
ADD ./default-metrics${LEGACY_TABLESPACE}.toml /default-metrics.toml

ENV DATA_SOURCE_NAME system/oracle@oracle/xe

EXPOSE 9161

USER 1000

ENTRYPOINT ["/oracledb_exporter"]
