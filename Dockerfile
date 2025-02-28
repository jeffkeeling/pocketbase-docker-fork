FROM alpine:latest as download
RUN apk add curl unzip
# Either keep dynamic version:
RUN curl -s https://get-latest.deno.dev/pocketbase/pocketbase?no-v=true >> tag.txt
# Or pin to specific version (recommended for production):
ENV PB_VERSION=0.22.31
RUN echo ${PB_VERSION} > tag.txt
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v$(cat tag.txt)/pocketbase_$(cat tag.txt)_linux_amd64.zip \
 && unzip pocketbase_$(cat tag.txt)_linux_amd64.zip \
 && chmod +x /pocketbase

FROM alpine:latest
RUN apk update && apk add --update git build-base ca-certificates && rm -rf /var/cache/apk/*
COPY --from=download /pocketbase /usr/local/bin/pocketbase

# Create the directory where PocketBase will store its data
RUN mkdir -p /root/pocketbase
RUN mkdir -p /root/pb_hooks

# Copy pb_hooks contents into the PocketBase data directory
COPY ./pb_hooks /root/pb_hooks

EXPOSE 8090

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8090/api/health || exit 1

ENTRYPOINT /usr/local/bin/pocketbase serve --http=0.0.0.0:8090 --dir=/root/pocketbase