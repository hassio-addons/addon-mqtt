#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# Configures Hivemq for use with MQTT Server & Web client
# ==============================================================================

# Only run this if the broker part of the add-on are enabled.
if bashio::config.true 'broker.enabled'; then

  # Set config file
  readonly CONFIG='/opt/mosquitto.conf'
  readonly CUSTOM_CONFIG='/config/mqtt/mosquitto.conf'
  readonly PWFILE='/opt/pwfile'
  readonly ACL_FILE='/opt/acl'
  readonly PERSISTENCE_LOCATION='/data/mosquitto/'

  if ! bashio::fs.directory_exists "$PERSISTENCE_LOCATION"; then
    mkdir -p "$PERSISTENCE_LOCATION"
  fi
  chown mosquitto:mosquitto -R "$PERSISTENCE_LOCATION" 

  # Remove config file if it exist
  if bashio::fs.file_exists "$CONFIG"; then
      rm "$CONFIG"    
  fi

  if bashio::config.true 'broker.enabled'; then
    bashio::log.info 'Adding configuration for MQTT Server...'
    # Create config file
    touch "$CONFIG"

    # Set default config
    { echo "log_dest stdout"; \
      echo "log_type websockets"; \
      echo "websockets_log_level 255"; \
      echo "persistence true"; \
      echo "persistence_location $PERSISTENCE_LOCATION"; } >> "$CONFIG"
    
    # Set websocket configurtation
    if bashio::config.true 'broker.enable_ws'; then
      bashio::log.info 'Setting configuration for websockets...'
      { echo "listener 1884";
      echo "protocol websockets";
      echo "socket_domain ipv4"; } >> "$CONFIG"
    fi

    # Set websocket SSL configurtation
    if bashio::config.true 'broker.enable_ws_ssl'; then
      { echo "listener 4884"; \
        echo "protocol websockets"; \
        echo "socket_domain ipv4"; \
        echo "cafile /ssl/$(bashio::config 'certfile')"; \
        echo "certfile /ssl/$(bashio::config 'certfile')"; \
        echo "keyfile /ssl/$(bashio::config 'keyfile')"; } >> "$CONFIG"
    fi

    # Set MQTT configurtation
    if bashio::config.true 'broker.enable_mqtt'; then
      bashio::log.info 'Setting configuration for mqtt...'
      echo "listener 1883" >> "$CONFIG"
      echo "protocol mqtt" >> "$CONFIG"
    fi

    # Set MQTT SSL configurtation
    if bashio::config.true 'broker.enable_mqtt_ssl'; then
      { echo "listener 4883"; \
        echo "protocol mqtt"; \
        echo "cafile /ssl/$(bashio::config 'certfile')"; \
        echo "certfile /ssl/$(bashio::config 'certfile')"; \
        echo "keyfile /ssl/$(bashio::config 'keyfile')"; } >> "$CONFIG"
    fi

    # Allow anonymous auth?
    if bashio::config.true 'broker.allow_anonymous'; then
      echo "allow_anonymous true" >> "$CONFIG"
    else
      echo "allow_anonymous false" >> "$CONFIG"
    fi

    # Create ACL file
    touch "$ACL_FILE"

    # Set username and password for the broker
    if ! bashio::config.true 'leave_front_door_open'; then
      touch "$PWFILE"
      echo "acl_file $ACL_FILE" >> "$CONFIG"
      echo "password_file $PWFILE" >> "$CONFIG"
      for key in $(bashio::config 'mqttusers | keys[]'); do
        username=$(bashio::config "mqttusers[${key}].username")
        password=$(bashio::config "mqttusers[${key}].password")
        mosquitto_passwd -b "$PWFILE" "$username" "$password"
        echo "user $username" >> "$ACL_FILE"
        for entry in $(bashio::config "mqttusers[${key}].topics"); do
          topic="$entry"
          if bashio::config.true "mqttusers[${key}].readonly"; then
            echo "topic read $topic" >> "$ACL_FILE"
          else
            echo "topic readwrite $topic" >> "$ACL_FILE"
          fi
        done
      done
    else
      # Remove pefile if it should not be used
      if bashio::fs.file_exists "$PWFILE"; then
          rm "$PWFILE"
      fi
    fi
  fi
  # Add custom mosquitto.config to config if one exist
  if bashio::fs.file_exists "$CUSTOM_CONFIG"; then
    bashio::log.info "Adding custom entries to configuration."
    # shellcheck disable=SC2002
    cat "$CUSTOM_CONFIG" | tee -a "$CONFIG" > /dev/null
  fi
fi