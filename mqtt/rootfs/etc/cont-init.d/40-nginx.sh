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
        rm /etc/nginx/nginx.conf
        mv /etc/nginx/nginx-ssl.conf /etc/nginx/nginx.conf

        certfile=$(hass.config.get 'certfile')
        keyfile=$(hass.config.get 'keyfile')

        sed -i "s/%%certfile%%/${certfile}/g" /etc/nginx/nginx.conf
        sed -i "s/%%keyfile%%/${keyfile}/g" /etc/nginx/nginx.conf
    fi

    # Handles the HTTP auth part
    if ! hass.config.has_value 'web.username'; then
        hass.log.warning "Username/password protection is disabled!"
        sed -i '/auth_basic.*/d' /etc/nginx/nginx.conf
    else
        username=$(hass.config.get 'web.username')
        password=$(hass.config.get 'web.password')
        htpasswd -bc /etc/nginx/.htpasswd "${username}" "${password}"
    fi
fi
