FROM alpine:3.13.2

COPY docs/ /docs/

RUN adduser -u 2004 -D docker
RUN chown -R docker:docker /docs

ENTRYPOINT ["/bin/sleep", "infinity"]
