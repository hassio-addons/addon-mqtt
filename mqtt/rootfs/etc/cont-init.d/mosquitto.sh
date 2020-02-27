#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: MQTT Server & Web client
# Configures Hivemq for use with MQTT Server & Web client
# ==============================================================================
readonly ACL_FILE='/opt/acl'
readonly CONFIG='/opt/mosquitto.conf'
readonly CUSTOM_CONFIG='/config/mqtt/mosquitto.conf'
readonly PERSISTENCE_LOCATION='/data/mosquitto/'
readonly PWFILE='/opt/pwfile'
declare password
declare username
declare usertopic

# Ensure certs exists when SSL is enabled
bashio::config.require.ssl

# Only run this if the broker part of the add-on are enabled.
if ! bashio::config.true 'broker'; then
  bashio::log.notice 'The MQTT Broker has been disabled!'
  exit 0
fi

# Ensure persistent storage location exists
if ! bashio::fs.directory_exists "$PERSISTENCE_LOCATION"; then
  mkdir -p "$PERSISTENCE_LOCATION"
fi
chown mosquitto:mosquitto -R "$PERSISTENCE_LOCATION"

bashio::log.info 'Adding configuration for MQTT Server...'

# Set default config
{
  echo "log_dest stdout";
  echo "log_type error";
  echo "log_type warning";
  echo "log_type notice ";
  echo "log_type information ";
  echo "log_type websockets";
  echo "persistence true";
  echo "persistence_location $PERSISTENCE_LOCATION";
  echo "listener 1883"
  echo "protocol mqtt"
  echo "listener 1884";
  echo "protocol websockets";
  echo "socket_domain ipv4";
} > "$CONFIG"

# Allow anonymous auth?
if bashio::config.true 'allow_anonymous'; then
  echo "allow_anonymous true" >> "$CONFIG"
else
  {
    echo "allow_anonymous false";
    echo "acl_file $ACL_FILE";
    echo "password_file $PWFILE";
  } >> "$CONFIG"
fi

# Set SSL configurtations
if bashio::config.true 'ssl'; then
  {
    echo "listener 4883";
    echo "protocol mqtt";
    echo "cafile /ssl/$(bashio::config 'certfile')";
    echo "certfile /ssl/$(bashio::config 'certfile')";
    echo "keyfile /ssl/$(bashio::config 'keyfile')";
    echo "listener 4884";
    echo "protocol websockets";
    echo "socket_domain ipv4";
    echo "cafile /ssl/$(bashio::config 'certfile')";
    echo "certfile /ssl/$(bashio::config 'certfile')";
    echo "keyfile /ssl/$(bashio::config 'keyfile')";
  } >> "$CONFIG"
fi

# Set username and password for the broker
for user in $(bashio::config 'mqttusers|keys'); do
  bashio::config.require.username "mqttusers[${user}].username"

  username=$(bashio::config "mqttusers[${user}].username")
  bashio::log.info "Setting up user ${username}"

  if bashio::config.true 'i_like_to_be_pwned'; then
    bashio::config.require.password "mqttusers[${user}].password"
  else
    bashio::config.require.safe_password "mqttusers[${user}].password"
  fi
  password=$(bashio::config "mqttusers[${user}].password")

  mosquitto_passwd -b "$PWFILE" "$username" "$password"
  echo "user $username" >> "$ACL_FILE"
  for topic in $(bashio::config "mqttusers[${user}].topics|keys"); do
    usertopic=$(bashio::config "mqttusers[${user}].topics[${topic}]")
    if bashio::config.true "mqttusers[${user}].readonly"; then
      echo "topic read $usertopic" >> "$ACL_FILE"
    else
      echo "topic readwrite $usertopic" >> "$ACL_FILE"
    fi
  done
done

# Add custom mosquitto.config to config if one exist
if bashio::fs.file_exists "$CUSTOM_CONFIG"; then
  bashio::log.info "Adding custom entries to configuration..."
  # shellcheck disable=SC2002
  cat "$CUSTOM_CONFIG" | tee -a "$CONFIG" > /dev/null
fi
