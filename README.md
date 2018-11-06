# Community Hass.io Add-ons: MQTT Server & Web client

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

[![GitLab CI][gitlabci-shield]][gitlabci]
![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

[![Bountysource][bountysource-shield]][bountysource]
[![Discord][discord-shield]][discord]
[![Community Forum][forum-shield]][forum]

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

Mosquitto MQTT Server bundled with Hivemq's web client.

![sample][screenshot]

## About

This add-on combines the power of [Hivemq][hivemq]'s
web-based MQTT client, and the powerful [Mosquitto][mosquitto]
broker (MQTT Server). With this, you can host your own MQTT server,
and inspect/publish messages using the built-in web client!

## Key features

- The Hivemq web service can connect to a WebSocket enabled MQTT Server,
  it will enable you to see or post messages to specific topics easily.
- The Mosquitto broker has multi-user support with ACL!
  _This allows you to limit the access of an MQTT user to a specific topic._
- With the ACL support, you can have a separate user for every
  device that connects to your MQTT server.
- You can also have read-only users that cannot post messages.

ACL = access control list.

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Hass.io add-on.

1. [Add our Hass.io add-ons repository][repository] to your Hass.io instance.
1. Install the "MQTT Server & Web client" add-on.
1. Start the "MQTT Server & Web client" add-on
1. Configure the "MQTT Server & Web client" add-on
1. Check the logs of the "MQTT Server & Web client"
  add-on to see if everything went well.
1. Click "OPEN WEB UI" to open the MQTT Server & Web client website.
1. Log in with your Home Assistant user.

**NOTE**: Starting the add-on might take a couple of minutes (especially the
first time starting the add-on).

**NOTE**: Do not add this repository to Hass.io, please use:
`https://github.com/hassio-addons/repository`.

## Docker status

![Supports armhf Architecture][armhf-shield]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports i386 Architecture][i386-shield]

[![Docker Layers][layers-shield]][microbadger]
[![Docker Pulls][pulls-shield]][dockerhub]

## Configuration Home assistant

**Note**: _Remember to restart the add-on when the configuration is changed._

**Note2**: _When changing from the official add-on to this one, make sure to change configuration.yaml broker ip. "broker: core-mosquitto" to "broker: IP eg, 192.168.1.*"_

```json
# Example configuration.yaml entry
mqtt:
  broker: <hass ip>
  username: !secret mqtt_username
  password: !secret mqtt_password
  client_id: home-assistant
```

## Configuration add-on

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```json
{
  "log_level": "info",
  "certfile": "fullchain.pem",
  "keyfile": "privkey.pem",
  "web": {
    "enabled": true,
    "ssl": true
  },
  "broker": {
    "enabled": true,
    "enable_ws": false,
    "enable_mqtt": false,
    "enable_ws_ssl": true,
    "enable_mqtt_ssl": true,
    "allow_anonymous": false
  },
  "mqttusers": [
    {
      "username": "MarryPoppins",
      "password": "Supercalifragilisticexpialidocious",
      "readonly": true,
      "topics": [
        "cmnd/"
      ]
    }
  ]
}
```

**Note**: _This is just an example, don't copy and paste it! Create your own!_

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`:  Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

### Option: `certfile`

The certificate file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default for Hass.io_

### Option: `keyfile`

The private key file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default for Hass.io_

### Option group `web`

---
The following options are for the option group: `web`. These settings
only apply to the Hivemq MQTT web client.

This web client can **only** connect to a WebSocket (WS) port, make sure you
have that enabled on the server (broker) you are connecting to.

#### Option `web`: `enable`

Flag to control if this service should be started.

#### Option `web`: `ssl`

Enables/Disables SSL (HTTPS) on the web client of this add-on. Set it `true`
to enable it, `false` otherwise.

### Option group `broker`

---
The following options are for the option group: `broker`. These settings
only apply to the Mosquitto broker.

#### Option `broker`: `enable`

Flag to control if this service should be started.

#### Option `broker`: `enable_ws`

Enables the WebSocket protocol on the broker.
The default WebSocket port is `1884`.

#### Option `broker`: `enable_mqtt`

Enables the MQTT protocol on the broker.
The default MQTT port is `1883`.

#### Option `broker`: `enable_ws_ssl`

Enables the WebSocket protocol on the broker with SSL support.
The default WebSocket port with SSL support is `4884`.

#### Option `broker`: `enable_mqtt_ssl`

Enables the MQTT protocol on the broker with SSL support.
The default MQTT port with SSL support is `4883`.

#### Option `broker`: `allow_anonymous`

Set this to `true` if you need to enable anonymous authentication.
**NB!: It is NOT a good idea having this enabled**

### Option group `mqttuser`

---
The following options are for the option group: `mqttuser`, And are only
applicable if the broker is enabled in this add-on.

_if you have `allow_anonymous` set to `false` you need at least one user._

#### Option `mqttuser`: `username`

Username for authenticating with the MQTT Server of this add-on.

Setting a username/password can be added as an extra line of defense,
to prevent users from using your installation for themselves.

This option is HIGHLY recommended in case you expose this add-on to the outside
world.

**Note**: _This option support secrets, e.g., `!secret mqtt_broker_username1`._

#### Option `mqttuser`: `password`

Password for authenticating with the MQTT Server of this add-on.

**Note**: _This option support secrets, e.g., `!secret mqtt_broker_password1`._

#### Option `mqttuser`: `readonly`

A flag to set user permission to `readonly` for the specified topics.

#### Option `mqttuser`: `topics`

A list of topics available to the user.
Wildcards like `#` and `+` are supported.

### Option: `i_like_to_be_pwned`

Adding this option to the add-on configuration allows to you bypass the
HaveIBeenPwned password requirement by setting it to `true`.

**Note**: _We STRONGLY suggest picking a stronger/safer password instead of
using this option! USE AT YOUR OWN RISK!_

### Option: `leave_front_door_open`

Adding this option to the add-on configuration allows you to disable
authentication on the Web Terminal by setting it to `true` and leaving the
username and password empty.

**Note**: _We STRONGLY suggest, not to use this, even if this add-on is
only exposed to your internal network. USE AT YOUR OWN RISK!_

## Embedding into Home Assistant

It is possible to embed the web client of this add-on directly into
Home Assistant, allowing you to access your the web client of this
add-on through the Home Assistant frontend.

Home Assistant provides the `panel_iframe` component, for these purposes.

Example configuration:

```yaml
panel_iframe:
  mqtt:
    title: MQTT
    icon: mdi:code-brackets
    url: https://addres.to.your.hass.io:5713
```

## Changelog & Releases

This repository keeps a change log using [GitHub's releases][releases]
functionality. The format of the log is based on
[Keep a Changelog][keepchangelog].

Releases are based on [Semantic Versioning][semver], and use the format
of ``MAJOR.MINOR.PATCH``. In a nutshell, the version will be incremented
based on the following:

- ``MAJOR``: Incompatible or major changes.
- ``MINOR``: Backwards-compatible new features and enhancements.
- ``PATCH``: Backwards-compatible bugfixes and package updates.

## Support

Got questions?

You have several options to get them answered:

- The [Community Hass.io Add-ons Discord chat server][discord] for add-on
  support and feature requests.
- The [Home Assistant Discord chat server][discord-ha] for general Home
  Assistant discussions and questions.
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

You could also [open an issue here][issue] GitHub.

## Contributing

This is an active open-source project. We are always open to people who want to
use the code or contribute to it.

We have set up a separate document containing our
[contribution guidelines](CONTRIBUTING.md).

Thank you for being involved! :heart_eyes:

## Authors & contributors

The original setup of this repository is by [Joakim Sørensen][ludeeus].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## We have got some Hass.io add-ons for you

Want some more functionality to your Hass.io Home Assistant instance?

We have created multiple add-ons for Hass.io. For a full list, check out
our [GitHub Repository][repository].

## License

MIT License

Copyright (c) 2018 Joakim Sørensen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[anchore-shield]: https://anchore.io/service/badges/image/67d1185473090e99d5ac5e1bb4d1aa2295117a9bd3d7abbf8cd8a71e331c8388
[anchore]: https://anchore.io/image/dockerhub/hassioaddons%2Funifi%3Alatest
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[bountysource-shield]: https://img.shields.io/bountysource/team/hassio-addons/activity.svg
[bountysource]: https://www.bountysource.com/teams/hassio-addons/issues
[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg
[buymeacoffee]: https://www.buymeacoffee.com/ludeeus
[commits-shield]: https://img.shields.io/github/commit-activity/y/hassio-addons/addon-mqtt.svg
[commits]: https://github.com/hassio-addons/addon-mqtt/commits/master
[contributors]: https://github.com/hassio-addons/addon-mqtt/graphs/contributors
[discord-ha]: https://discord.gg/c5DvZ4e
[discord-shield]: https://img.shields.io/discord/478094546522079232.svg
[discord]: https://discord.me/hassioaddons
[dockerhub]: https://hub.docker.com/r/hassioaddons/mqtt
[forum-shield]: https://img.shields.io/badge/community-forum-brightgreen.svg
[forum]: https://community.home-assistant.io/t/community-hass-io-add-ons-mqtt-server-web-client/70376
[ludeeus]: https://github.com/ludeeus
[gitlabci-shield]: https://gitlab.com/hassio-addons/addon-mqtt/badges/master/pipeline.svg
[gitlabci]: https://gitlab.com/hassio-addons/addon-mqtt/pipelines
[hivemq]: https://www.hivemq.com/
[home-assistant]: https://home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/hassio-addons/addon-mqtt/issues
[keepchangelog]: http://keepachangelog.com/en/1.0.0/
[layers-shield]: https://images.microbadger.com/badges/image/hassioaddons/mqtt.svg
[license-shield]: https://img.shields.io/github/license/hassio-addons/addon-mqtt.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2018.svg
[microbadger]: https://microbadger.com/images/hassioaddons/mqtt
[mosquitto]: https://mosquitto.org/
[project-stage-shield]: https://img.shields.io/badge/project%20stage-experimental-yellow.svg
[pulls-shield]: https://img.shields.io/docker/pulls/hassioaddons/mqtt.svg
[reddit]: https://reddit.com/r/homeassistant
[releases-shield]: https://img.shields.io/github/release/hassio-addons/addon-mqtt.svg
[releases]: https://github.com/hassio-addons/addon-mqtt/releases
[repository]: https://github.com/hassio-addons/repository
[screenshot]: https://github.com/hassio-addons/addon-mqtt/raw/master/images/image.png
[semver]: http://semver.org/spec/v2.0.0.htm
