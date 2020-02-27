ARG BUILD_FROM=hassioaddons/base:7.0.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Sets working directory
WORKDIR /app

# Versions
ENV HIVEMQ='b2043e7fcbd5897a3799869d42c6202122221fbc' \
    LIBWEBSOCKETS='3.1.0' \
    MOSQUITTO='1.6.4'

# Setup base
# hadolint ignore=DL3003
RUN \
  apk add --no-cache --virtual .build-dependencies \
    git=2.24.1-r0 \
    cmake=3.15.5-r0 \
    build-base=0.5-r1 \
    zlib-dev=1.2.11-r3 \
    openssl-dev=1.1.1d-r3 \
  \
  && apk add --no-cache \
    nginx=1.16.1-r6 \
    lua-resty-http=0.15-r0 \
    nginx-mod-http-lua=1.16.1-r6 \
  \
  && git clone --depth=1 \
    https://github.com/hivemq/hivemq-mqtt-web-client.git /app \
  && git checkout "${HIVEMQ}" \
  \
  && git clone --branch "v${LIBWEBSOCKETS}" --depth=1 \
    https://github.com/warmcat/libwebsockets.git /tmp/libwebsockets \
  \
  && mkdir -p /tmp/libwebsockets/build \
  && cd /tmp/libwebsockets/build \
  && cmake .. \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLWS_IPV6=OFF \
    -DLWS_WITHOUT_BUILTIN_GETIFADDRS=ON \
    -DLWS_WITHOUT_CLIENT=ON \
    -DLWS_WITHOUT_EXTENSIONS=ON \
    -DLWS_WITHOUT_TESTAPPS=ON \
    -DLWS_WITH_SHARED=OFF \
    -DLWS_WITH_ZIP_FOPS=OFF \
    -DLWS_WITH_ZLIB=OFF \
  && make \
  && make install \
  \
  && git clone --branch "v${MOSQUITTO}" --depth=1 \
      https://github.com/eclipse/mosquitto.git /tmp/mosquitto \
  \
  && cd /tmp/mosquitto \
  && make \
    WITH_ADNS=no \
    WITH_DOCS=no \
    WITH_MEMORY_TRACKING=no \
    WITH_TLS_PSK=no \
    WITH_WEBSOCKETS=yes \
    prefix=/usr \
    binary \
  && make WITH_DOCS=no install binary \
  \
  && addgroup -S mosquitto \
  && adduser -S -D -H -h /var/empty -s /sbin/nologin \
    -G mosquitto -g mosquitto mosquitto \
  \
  && apk del --no-cache --purge .build-dependencies \
  && rm -fr \
    /etc/nginx \
    /opt/mosquitto.conf \
    /opt/acl \
    /tmp/*

# Copy root filesystem
COPY rootfs /

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
    org.label-schema.vendor="Home Assistant Community Add-ons"
