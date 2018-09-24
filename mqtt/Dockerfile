ARG BUILD_FROM=hassioaddons/base:2.3.0
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
  apk add --no-cache --virtual .build-dependencies \
    git=2.18.0-r0 \
  \
  && apk add --no-cache \
    apache2-utils=2.4.34-r0 \
    nginx=1.14.0-r1 \
    libwebsockets=2.4.0-r1 \
    mosquitto=1.4.15-r0 \
  \
  && git clone --depth=1 \
    https://github.com/hivemq/hivemq-mqtt-web-client.git /app \
  \
  && mkdir /opt \
  \
  && apk del --purge .build-dependencies
  
# Build arugments
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
    org.label-schema.url="https://community.home-assistant.io/t/community-hass-io-add-on-mqtt/XXXX" \
    org.label-schema.usage="https://github.com/hassio-addons/addon-mqtt/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/hassio-addons/addon-mqtt" \
    org.label-schema.vendor="Community Hass.io Add-ons"
