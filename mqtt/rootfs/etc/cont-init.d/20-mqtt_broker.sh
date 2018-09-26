#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# Configures Hivemq for use with MQTT Server & Web client
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# Only run this if the broker part of the add-on are enabled.
if hass.config.true 'broker.enabled'; then

  # Set config file
  readonly CONFIG='/opt/mosquitto.conf'
  readonly PWFILE='/opt/pwfile'
  readonly ACL_FILE='/opt/acl'
  readonly PERSISTENCE_LOCATION='/data/mosquitto/'

  if ! hass.directory_exists "$PERSISTENCE_LOCATION"; then
    mkdir -p "$PERSISTENCE_LOCATION"    
  fi
  chown mosquitto:mosquitto -R "$PERSISTENCE_LOCATION" 

  # Remove config file if it exist
  if hass.file_exists "$CONFIG"; then
      rm "$CONFIG"    
  fi

  if hass.config.true 'broker.enabled'; then
    hass.log.info 'Adding configuration for MQTT Server...'
    # Create config file
    touch "$CONFIG"

    # Set default config
    { echo "log_dest stdout"; \
      echo "persistence true"; \
      echo "persistence_location $PERSISTENCE_LOCATION"; } >> "$CONFIG"
    
    # Set websocket configurtation
    if hass.config.true 'broker.enable_ws'; then
      hass.log.info 'Setting configuration for websockets...'
      echo "listener 1884" >> "$CONFIG"
      echo "protocol websockets" >> "$CONFIG"
    fi

    # Set websocket SSL configurtation
    if hass.config.true 'broker.enable_ws_ssl'; then
      { echo "listener 4884"; \
        echo "protocol websockets"; \
        echo "cafile /ssl/$(hass.config.get 'certfile')"; \
        echo "certfile /ssl/$(hass.config.get 'certfile')"; \
        echo "keyfile /ssl/$(hass.config.get 'keyfile')"; } >> "$CONFIG"
    fi

    # Set MQTT configurtation
    if hass.config.true 'broker.enable_mqtt'; then
      hass.log.info 'Setting configuration for mqtt...'
      echo "listener 1883" >> "$CONFIG"
      echo "protocol mqtt" >> "$CONFIG"
    fi

    # Set MQTT SSL configurtation
    if hass.config.true 'broker.enable_mqtt_ssl'; then
      { echo "listener 4883"; \
        echo "protocol mqtt"; \
        echo "cafile /ssl/$(hass.config.get 'certfile')"; \
        echo "certfile /ssl/$(hass.config.get 'certfile')"; \
        echo "keyfile /ssl/$(hass.config.get 'keyfile')"; } >> "$CONFIG"
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
