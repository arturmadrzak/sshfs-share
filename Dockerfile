FROM "library/alpine:latest"

LABEL maintainer="Artur Mądrzak <artur@madrzak.eu>"

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Install requirements to build image
# hadolint ignore=DL3018
RUN passwd -d root && apk add --no-cache --upgrade \
    openssh-server \
    openssh-sftp-server

COPY entrypoint.sh /usr/local/sbin/

ENTRYPOINT [ "/usr/local/sbin/entrypoint.sh" ]
