#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: MQTT Server & Web client
# This files check if all user configuration requirements are met
# ==============================================================================

# Ensure not both web & mqtt are disabled
if  bashio::config.false 'web.enable' && bashio::config.false 'broker.enable'; then
    bashio::exit.nok 'Both Web & MQTT are disabled. Aborting.'
fi

# Notify user if web is disabled
if bashio::config.false 'web.enable'; then
    bashio::log.notice 'The Web client has been disabled!'
fi

# Notify user if mqtt is disabled
if bashio::config.false 'broker.enable'; then
    bashio::log.notice 'The MQTT Broker has been disabled!'
fi

# Checks for the web client
if bashio::config.true 'web.enable'; then

    if ! bashio::config.true 'leave_front_door_open'; then
        bashio::config.require.username 'web.username';
        bashio::config.require.password 'web.password';
    fi

    # We need a username to go with the password
    if bashio::config.is_empty 'web.username' \
        && bashio::config.has_value 'web.password';
    then
        bashio::log.fatal
        bashio::log.fatal 'You have set a Web client password using the'
        bashio::log.fatal '"web.password" option, but the "web.username" option'
        bashio::log.fatal 'is left empty. Login without a username but with a'
        bashio::log.fatal 'password is not possible.'
        bashio::log.fatal
        bashio::log.fatal 'Please set a username in the "web.username" option.'
        bashio::log.fatal
        bashio::exit.nok
    fi

    # We need a password to go with the username
    if bashio::config.has_value 'web.username' \
        && bashio::config.is_empty 'web.password';
    then
        bashio::log.fatal
        bashio::log.fatal 'You have set a Web client username using the'
        bashio::log.fatal '"web.username" option, but the "web.password" option'
        bashio::log.fatal 'is left empty. Login without a password but with a'
        bashio::log.fatal 'username is not possible.'
        bashio::log.fatal
        bashio::log.fatal 'Please set a password in the "web.password" option.'
        bashio::log.fatal
        bashio::exit.nok
    fi

    # Require a secure password
    if bashio::config.has_value 'web.password' \
        && ! bashio::config.true 'i_like_to_be_pwned'; then
        bashio::config.require.safe_password 'web.password'
    fi

    bashio::config.require.ssl 'web.ssl' 'certfile' 'keyfile'
fi

# Checks for the mqtt broker
if bashio::config.true 'broker.enable'; then

    if ! bashio::config.true 'leave_front_door_open'; then
        bashio::config.require.username 'broker.username';
        bashio::config.require.password 'broker.password';
    fi

    # We need a username to go with the password
    if bashio::config.is_empty 'mqttusers[0].username' \
        && bashio::config.has_value 'broker.password';
    then
        bashio::log.fatal
        bashio::log.fatal 'You have set a password using the'
        bashio::log.fatal '"mqttusers" option, but the username for it'
        bashio::log.fatal 'is left empty. Login without a username but with a'
        bashio::log.fatal 'password is not possible.'
        bashio::log.fatal
        bashio::log.fatal 'Please set a username in the "mqttusers" option.'
        bashio::log.fatal
        bashio::exit.nok
    fi

    # We need a password to go with the username
    if bashio::config.has_value 'broker.username' \
        && bashio::config.is_empty 'broker.password';
    then
        bashio::log.fatal
        bashio::log.fatal 'You have set a password using the'
        bashio::log.fatal '"mqttusers" option, but the password for it'
        bashio::log.fatal 'is left empty. Login without a password but with a'
        bashio::log.fatal 'username is not possible.'
        bashio::log.fatal
        bashio::log.fatal 'Please set a password in the "mqttusers" option.'
        bashio::log.fatal
        bashio::exit.nok
    fi

    # Require a secure password
    if bashio::config.has_value 'mqttusers[0].password' \
        && ! bashio::config.true 'i_like_to_be_pwned'; then
        bashio::config.require.safe_password 'mqttusers[0].password'
    fi

    bashio::config.require.ssl 'broker.enable_ws_ssl' 'certfile' 'keyfile'
    bashio::config.require.ssl 'broker.enable_ssl' 'certfile' 'keyfile'
fi