#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# This files check if all user configuration requirements are met
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# Checks for web client
if hass.config.true 'web.enabled'; then
    # Require username / password
    if ! hass.config.has_value 'web.username' \
        && ! ( \
            hass.config.exists 'leave_front_door_open' \
            && hass.config.true 'leave_front_door_open' \
        );
    then
        hass.die 'You need to set a username!'
    fi
    
    if ! hass.config.has_value 'web.password' \
        && ! ( \
            hass.config.exists 'leave_front_door_open' \
            && hass.config.true 'leave_front_door_open' \
        );
    then
        hass.die 'You need to set a password!';
    fi
    
    # Require a secure password
    if hass.config.has_value 'web.password' \
        && ! hass.config.is_safe_password 'web.password'; then
        hass.die "Please choose a different password, this one is unsafe!"
    fi
fi

# Checks for broker
if hass.config.true 'broker.enabled'; then
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
