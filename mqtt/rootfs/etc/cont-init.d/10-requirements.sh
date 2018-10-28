#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# This files check if all user configuration requirements are met
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# Checks for broker
if hass.config.true 'broker.enabled' \
    && hass.config.false 'broker.allow_anonymous' \
    && ! ( \
        hass.config.exists 'leave_front_door_open' \
        && hass.config.true 'leave_front_door_open' \
    ); then
    if ! hass.config.has_value 'mqttusers[0].username'; then
        hass.die 'Missing username for MQTT User'
    fi
    if ! hass.config.has_value 'mqttusers[0].password'; then
        hass.die 'Missing password for MQTT User'
    fi
fi

# Check SSL requirements, if enabled
if hass.config.true 'broker.enable_ws_ssl' \
    || hass.config.true 'broker.enable_mqtt_ssl' \
    || (hass.config.true 'web.enabled' && hass.config.true 'web.ssl'); then
    if ! hass.config.has_value 'certfile'; then
        hass.die 'SSL is enabled, but no certfile was specified'
    fi

    if ! hass.config.has_value 'keyfile'; then
        hass.die 'SSL is enabled, but no keyfile was specified'
    fi

    if ! hass.file_exists "/ssl/$(hass.config.get 'certfile')"; then
        hass.die 'The configured certfile is not found'
    fi

    if ! hass.file_exists "/ssl/$(hass.config.get 'keyfile')"; then
        hass.die 'The configured keyfile is not found'
    fi
fi
