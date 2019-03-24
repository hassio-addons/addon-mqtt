#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# Configures NGINX for use with MQTT Server & Web client
# ==============================================================================

declare certfile
declare keyfile

# Only run this if the web part of the add-on are enabled.
if bashio::config.true 'web.enabled'; then
    # Remove LUA auth if leave_front_door_open == True
    if bashio::config.true 'leave_front_door_open'; then
        sed -i "/access_by_lua_file/d" /etc/nginx/nginx.conf
        sed -i "/access_by_lua_file/d" /etc/nginx/nginx-ssl.conf
        sed -i "/load_module/d" /etc/nginx/nginx.conf
        sed -i "/load_module/d" /etc/nginx/nginx-ssl.conf
        sed -i "/lua_shared_dict/d" /etc/nginx/nginx.conf
        sed -i "/lua_shared_dict/d" /etc/nginx/nginx-ssl.conf
    fi
    # Enable SSL
    if bashio::config.true 'web.ssl'; then
        certfile=$(bashio::config 'certfile')
        keyfile=$(bashio::config 'keyfile')
        sed -i "s/%%certfile%%/${certfile}/g" /etc/nginx/nginx-ssl.conf
        sed -i "s/%%keyfile%%/${keyfile}/g" /etc/nginx/nginx-ssl.conf
    fi
fi
