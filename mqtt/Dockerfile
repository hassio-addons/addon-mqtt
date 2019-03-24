ARG BUILD_FROM=hassioaddons/base:3.0.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Sets working directory
WORKDIR /app

# Copy root filesystem
COPY rootfs /

# Setup base
RUN \
  apk add --no-cache \
    nginx=1.14.2-r0 \
    lua-resty-http=0.12-r1 \
    nginx-mod-http-lua=1.14.2-r0 \
    mosquitto=1.5.6-r0 \
  \
  && curl -J -L -o /tmp/web.zip \
    "https://github.com/hivemq/hivemq-mqtt-web-client/archive/46338a633eb26bc9f6d8d8ff82f8f2aedc004a57.zip" \
  \
  && unzip -d /tmp /tmp/web.zip \
  && mv /tmp/hivemq-mqtt-web-client-*/* /app \
  \
  && rm -fr /tmp/*

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="MQTT Server & Web client" \
    io.hass.description="Mosquitto MQTT Server bundled with Hivemq's web client." \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Joakim Sørensen @ludeeus <ludeeus@gmail.com>" \
    org.label-schema.description="Mosquitto MQTT Server bundled with Hivemq's web client." \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="MQTT Server & Web client" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://community.home-assistant.io/t/community-hass-io-add-ons-mqtt-server-web-client/70376" \
    org.label-schema.usage="https://github.com/hassio-addons/addon-mqtt/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/hassio-addons/addon-mqtt" \
    org.label-schema.vendor="Community Hass.io Add-ons"
