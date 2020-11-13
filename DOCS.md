# Home Assistant Add-on: KDB Tick

> This doc needs to be updated

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Git pull" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

In the configuration section, set the repository field to your repository's
clone URL and check if any other fields need to be customized to work with
your repository. Next,

1. Start the add-on.
2. Check the add-on log output to see the result.

If the log doesn't end with an error

## Configuration

Add-on configuration:

```yaml
logins: user
anonymous": false
auto_restart: false
restart_ignore:
  - ui-lovelace.yaml
  - ".gitignore"
  - exampledirectory/
repeat:
  active: false
  interval: 300
```

### Option: `logins` (required)

Name of the tracked repository. Leave this as `origin` if you are unsure.

### Option: `anaymous` (required)

something

### Option: `auto_restart` (required)

`true`/`false`: Restart Home Assistant when the configuration has changed (and is valid).

### Option: `restart_ignore` (optional)

When `auto_restart` is enabled, changes to these files will not make HA restart. Full directories to ignore can be specified.

### Option group: `repeat`

The following options are for the option group: `repeat` and configure the Git pull add-on to poll the repository for updates periodically automatically.

#### Option: `repeat.active` (required)

`true`/`false`: Enable/disable automatic polling.

#### Option: `repeat.interval` (required)

The interval in seconds to poll the repo for if automatic polling is enabled.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
