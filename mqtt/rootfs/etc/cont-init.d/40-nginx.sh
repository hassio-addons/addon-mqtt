#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# Configures NGINX for use with MQTT Server & Web client
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

declare certfile
declare keyfile

# Only run this if the web part of the add-on are enabled.
if hass.config.true 'web.enabled'; then
    # Enable SSL
    if hass.config.true 'web.ssl'; then
        certfile=$(hass.config.get 'certfile')
        keyfile=$(hass.config.get 'keyfile')

        sed -i "s/%%certfile%%/${certfile}/g" /etc/nginx/nginx-ssl.conf
        sed -i "s/%%keyfile%%/${keyfile}/g" /etc/nginx/nginx-ssl.conf
    fi
fi
