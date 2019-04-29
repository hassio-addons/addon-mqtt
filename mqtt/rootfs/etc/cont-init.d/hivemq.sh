#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# This files adds some patches to the add-on
# ==============================================================================
readonly CONFIG='/app/config.js'

# Changes to the UI of Hivemq
patch /app/index.html /patches/index

# Remove config file if it exist
if bashio::fs.file_exists "$CONFIG"; then
    rm "$CONFIG"
fi

# Create config file
touch "$CONFIG"
echo "websocketserver = '""';" >> "$CONFIG"

# Set default WS port and enable SSL for broker connection
if bashio::config.true 'ssl'; then
    sed -i 's/%%SSL_VALUE%%/checked="checked"/' /app/index.html
    echo 'websocketport = 4884;' >> "$CONFIG"
else
    sed -i 's/%%SSL_VALUE%%//' /app/index.html
    echo 'websocketport = 1884;' >> "$CONFIG"
fi
