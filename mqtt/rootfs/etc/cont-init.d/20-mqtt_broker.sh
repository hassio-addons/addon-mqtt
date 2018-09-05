#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Broker & Web client
# Configures Hivemq for use with MQTT Broker & Web client
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# Set config file
CONFIG='/data/mosquitto.conf'

# Remove config file if it exist
if hass.file_exists "$CONFIG"; then
    rm "$CONFIG"    
fi

if hass.config.true 'broker.enabled'; then
  hass.log.info 'Adding configuration for MQTT broker...'
  # Create config file
  touch "$CONFIG"

  # Set default config
  echo "log_dest stdout" >> $CONFIG
  echo "persistence true" >> $CONFIG
  echo "persistence_location /data/" >> $CONFIG
  
  # Set websocket configurtation
  if hass.config.true 'broker.enable_ws'; then
    hass.log.info 'Setting configuration for websockets...'
    echo "listener 1884" >> $CONFIG
    echo "protocol websockets" >> $CONFIG

    # Set SSL configuration.
    if hass.config.true 'broker.ssl'; then
      echo "cafile  /ssl/$(hass.config.get 'certfile')" >> $CONFIG
      echo "certfile   /ssl/$(hass.config.get 'certfile')" >> $CONFIG
      echo "keyfile   /ssl/$(hass.config.get 'keyfile')" >> $CONFIG
    fi
  fi

  # Set MQTT configurtation
  if hass.config.true 'broker.enable_ws'; then
    hass.log.info 'Setting configuration for mqtt...'
    echo "listener 1883" >> $CONFIG
    echo "protocol mqtt" >> $CONFIG
    
    # Set SSL configuration.
    if hass.config.true 'broker.ssl'; then
      echo "cafile  /ssl/$(hass.config.get 'certfile')" >> $CONFIG
      echo "certfile   /ssl/$(hass.config.get 'certfile')" >> $CONFIG
      echo "keyfile   /ssl/$(hass.config.get 'keyfile')" >> $CONFIG
    fi
  fi

  # Allow anonymous auth?
  if hass.config.true 'broker.allow_anonymous'; then
    echo "allow_anonymous true" >> $CONFIG
  else
    echo "allow_anonymous false" >> $CONFIG
  fi

  # Set username and password for the broker
  if hass.config.has_value 'broker.username' \
      && hass.config.has_value 'broker.password'; then
    touch /data/pwfile
    mosquitto_passwd -b /data/pwfile "$(hass.config.get 'broker.username')" "$(hass.config.get 'broker.password')"
  else
    # Remove pefile if it should not be used
    if hass.file_exists 'rm /data/pwfile'; then
        rm rm /data/pwfile 
    fi
  fi
fi