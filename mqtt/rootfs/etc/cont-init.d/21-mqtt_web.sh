#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# Configures Hivemq for use with MQTT Server & Web client
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# Only run this if the web part of the add-on are enabled.
if hass.config.true 'web.enabled'; then

    readonly CONFIG='/app/config.js'

    # Remove config file if it exist
    if hass.file_exists "$CONFIG"; then
        rm "$CONFIG"    
    fi

    # Create config file
    touch "$CONFIG"
    echo "websocketserver = '""';" >> "$CONFIG" 

    # Set default WS port and enable SSL for broker connection
    if hass.config.true 'broker.enable_ws_ssl'; then
        sed -i 's/%%SSL_VALUE%%/checked="checked"/' /app/index.html
        echo 'websocketport = 4884;' >> "$CONFIG" 
    else
        sed -i 's/%%SSL_VALUE%%//' /app/index.html
        echo 'websocketport = 1884;' >> "$CONFIG" 
    fi
fi
