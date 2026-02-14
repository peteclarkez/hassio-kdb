# Home Assistant Add-on: KDB-X Tick

KDB-X Tick database for storing Home Assistant events with high-performance time-series capabilities.

![Supports amd64 Architecture][amd64-shield]
![Supports aarch64 Architecture][aarch64-shield]

This add-on runs a complete KDB-X tick system that captures Home Assistant events and stores them in a time-series database for analysis and querying.

## Features

- **Tickerplant (Port 5010)**: Receives and logs events in real-time
- **RDB (Port 5011)**: Real-time database for today's data
- **HDB (Port 5012)**: Historical database for past days
- **Gateway (Port 5013)**: Unified query interface across RDB and HDB

## Architecture

```
Home Assistant → .u.updjson → Tickerplant → RDB → HDB
                                  ↓
                              Gateway (unified queries)
```

## Requirements

- **KDB-X License**: You need a valid KX license (base64 encoded) configured in the add-on options
- **kdbx-tick Docker Image**: The `peteclarkez/kdbx-tick` image (pulled automatically during build)

## Quick Start

### 1. Build locally

```bash
export KX_LICENSE_B64=$(base64 -w0 ~/.kx/kc.lic)

docker build -t hassio-kdb .
```

### 2. Run

```bash
docker run -d \
  -p 5010:5010 -p 5011:5011 -p 5012:5012 -p 5013:5013 \
  -v "$(pwd)/test-data:/data" \
  --name hassio-kdb \
  hassio-kdb
```

The upstream `peteclarkez/kdbx-tick` image is pulled automatically during the build.

### CI/CD

Tagged releases (e.g. `v5.0.5`) automatically build and push multi-arch images
(`amd64`, `aarch64`) to Docker Hub via GitHub Actions.
## Data Schema

The `hass_event` table stores Home Assistant events:

| Column    | Type      | Description                    |
|-----------|-----------|--------------------------------|
| time      | timestamp | Event timestamp                |
| sym       | symbol    | Domain (sensor, binary_sensor) |
| entity_id | symbol    | Entity identifier              |
| nvalue    | float     | Numeric value                  |
| svalue    | mixed     | String value                   |
| eattr     | mixed     | Entity attributes dictionary   |

## Publishing Events

Events are published using the `.u.updjson` function:

```q
h:hopen `:localhost:5010
h ".u.updjson[`hass_event; \"{\\\"time\\\": 1704877539.956502, \\\"host\\\": \\\"hass_event\\\", \\\"event\\\": {\\\"domain\\\": \\\"sensor\\\", \\\"entity_id\\\": \\\"temperature\\\", \\\"attributes\\\": {\\\"unit\\\": \\\"C\\\"}, \\\"value\\\": 22.5, \\\"svalue\\\": \\\"22.5\\\"}}\"]"
```

## Querying Data

Connect to the Gateway on port 5013 for unified queries:

```q
h:hopen `:localhost:5013

/ Check status
h "status[]"

/ Query today's data
h "select from hass_event"

/ Get RDB statistics
h "rdbStats[]"
```

[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
