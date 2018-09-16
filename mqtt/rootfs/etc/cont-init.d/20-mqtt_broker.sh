#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Broker & Web client
# Configures Hivemq for use with MQTT Broker & Web client
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# Only run this if the broker part of the add-on are enabled.
if hass.config.true 'broker.enabled'; then

  # Set config file
  CONFIG='/opt/mosquitto.conf'
  PWFILE='/opt/pwfile'
  ACL_FILE='/opt/acl'

  # Remove config file if it exist
  if hass.file_exists "$CONFIG"; then
      rm "$CONFIG"    
  fi

  if hass.config.true 'broker.enabled'; then
    hass.log.info 'Adding configuration for MQTT broker...'
    # Create config file
    touch "$CONFIG"

    # Set default config
    echo "log_dest stdout" >> "$CONFIG"
    echo "persistence true" >> "$CONFIG"
    echo "persistence_location /data/" >> "$CONFIG"
    
    # Set websocket configurtation
    if hass.config.true 'broker.enable_ws'; then
      hass.log.info 'Setting configuration for websockets...'
      echo "listener 1884" >> "$CONFIG"
      echo "protocol websockets" >> "$CONFIG"

      # Set SSL configuration.
      if hass.config.true 'broker.ssl'; then
        echo "cafile  /ssl/$(hass.config.get 'certfile')" >> "$CONFIG"
        echo "certfile   /ssl/$(hass.config.get 'certfile')" >> "$CONFIG"
        echo "keyfile   /ssl/$(hass.config.get 'keyfile')" >> "$CONFIG"
      fi
    fi

    # Set MQTT configurtation
    if hass.config.true 'broker.enable_ws'; then
      hass.log.info 'Setting configuration for mqtt...'
      echo "listener 1883" >> "$CONFIG"
      echo "protocol mqtt" >> "$CONFIG"
      
      # Set SSL configuration.
      if hass.config.true 'broker.ssl'; then
        echo "cafile  /ssl/$(hass.config.get 'certfile')" >> "$CONFIG"
        echo "certfile   /ssl/$(hass.config.get 'certfile')" >> "$CONFIG"
        echo "keyfile   /ssl/$(hass.config.get 'keyfile')" >> "$CONFIG"
      fi
    fi

    # Allow anonymous auth?
    if hass.config.true 'broker.allow_anonymous'; then
      echo "allow_anonymous true" >> "$CONFIG"
    else
      echo "allow_anonymous false" >> "$CONFIG"
    fi

    # Set username and password for the broker
    if ! hass.config.true 'leave_front_door_open'; then
      touch "$PWFILE"
      echo "acl_file $ACL_FILE" >> "$CONFIG"
      for key in $(hass.config.get 'mqttusers | keys[]'); do
        username=$(hass.config.get "mqttusers[${key}].username")
        password=$(hass.config.get "mqttusers[${key}].password")
        mosquitto_passwd -b "$PWFILE" "$username" "$password"
        echo "user $username" >> "$ACL_FILE"
        for entry in $(hass.config.get "mqttusers[${key}].topics"); do
          topic="$entry"
          if hass.config.true "mqttusers[${key}].readonly"; then
            echo "topic readwrite $topic" >> "$ACL_FILE"
          else
            echo "topic $topic" >> "$ACL_FILE"
          fi
        done
      done
    else
      # Remove pefile if it should not be used
      if hass.file_exists "$PWFILE"; then
          rm "$PWFILE"
      fi
    fi
  fi
fi
