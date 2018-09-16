#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Broker & Web client
# Configures Hivemq for use with MQTT Broker & Web client
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# Only run this if the web part of the add-on are enabled.
if hass.config.true 'web.enabled'; then

    CONFIG='/app/config.js'

    # Remove config file if it exist
    if hass.file_exists "$CONFIG"; then
        rm "$CONFIG"    
    fi

    # Create config file
    touch "$CONFIG"
    echo "websocketserver = '""';" >> "$CONFIG" 

    # Set default WS port
    echo 'websocketport = 1884;' >> "$CONFIG" 

    # Enable SSL for broker connection if enabled for the broker
    if hass.config.true 'broker.enable_ws_ssl'; then
        sed -i 's/%%SSL_VALUE%%/checked="checked"/' /app/index.html
    else
        sed -i 's/%%SSL_VALUE%%//' /app/index.html
    fi
fi
