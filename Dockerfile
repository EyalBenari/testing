# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-testing"
LABEL REPO="https://github.com/lacion/testing"

ENV PROJPATH=/go/src/github.com/lacion/testing

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/lacion/testing
WORKDIR /go/src/github.com/lacion/testing

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/lacion/testing"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/testing/bin

WORKDIR /opt/testing/bin

COPY --from=build-stage /go/src/github.com/lacion/testing/bin/testing /opt/testing/bin/
RUN chmod +x /opt/testing/bin/testing

# Create appuser
RUN adduser -D -g '' testing
USER testing

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/testing/bin/testing"]
