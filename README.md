# Asynchro

## Build Dependencies

- secp256k1
- sqlite3

```sh
v install --once fleximus.vdns
v install --once ismyhc/vbech32
v install --once --git https://gitlab.com/syobon/secp256k1
v install --once --git https://github.com/bstnbuck/V-crypto
```

## API Support

### gateway

| endpoint           | support |
|--------------------|:-------:|
| /services          |    ✅    |
| /tos               |    ❌    |
| /code-of-conduct   |    ❌    |
| /register-template |    ❌    |
| /health            |    ❌    |
| /metrics           |    ❌    |

### web

| endpoint      | support |
|---------------|:-------:|
| /web          |    ❌    |
| /web/login    |    ❌    |
| /web/welcome  |    ❌    |
| /web/register |    ✴️    |


### api

| endpoint                               | support |
|----------------------------------------|:-------:|
| /api/v1/commit                         |    ✴️    |
| /api/v1/domain                         |    ✅    |
| /api/v1/domain/:id                     |    ❌    |
| /api/v1/domains                        |    ❌    |
| /api/v1/entity                         |    ✅    |
| /api/v1/entity/:id                     |    ✴️    |
| /api/v1/entity/:id/acking              |    ✅    |
| /api/v1/entity/:id/acker               |    ✅    |
| /api/v1/entities                       |    ❌    |
| /api/v1/message/:id                    |    ❌    |
| /api/v1/message/:id/associations       |    ❌    |
| /api/v1/message/:id/associationcounts  |    ❌    |
| /api/v1/message/:id/associations/mine  |    ❌    |
| /api/v1/association/:id                |    ❌    |
| /api/v1/profile/:id                    |    ❌    |
| /api/v1/profile/:id/associations       |    ❌    |
| /api/v1/profile/:owner/:semanticid     |    ✅    |
| /api/v1/profiles                       |    ✅    |
| /api/v1/timeline/:id                   |    ✅    |
| /api/v1/timeline/:id/query             |    ❌    |
| /api/v1/timeline/:id/associations      |    ❌    |
| /api/v1/timelines                      |    ❌    |
| /api/v1/timelines/mine                 |    ❌    |
| /api/v1/timelines/recent               |    ❌    |
| /api/v1/timelines/range                |    ❌    |
| /api/v1/timelines/chunks               |    ❌    |
| /api/v1/timelines/retracted            |    ❌    |
| /api/v1/timelines/realtime             |    ✴️    |
| /api/v1/chunks/itr                     |    ❌    |
| /api/v1/chunks/body                    |    ❌    |
| /api/v1/kv/:key                        |    ✅    |
| /api/v1/auth/passport                  |    ❌    |
| /api/v1/key/:id                        |    ❌    |
| /api/v1/keys/mine                      |    ❌    |
| /api/v1/subscription/:id               |    ❌    |
| /api/v1/subscription/:id/associations  |    ❌    |
| /api/v1/subscriptions/mine             |    ❌    |
| /api/v1/repository                     |    ❌    |
| /api/v1/repositories/sync              |    ❌    |
| /api/v1/job/:id                        |    ❌    |
| /api/v1/jobs                           |    ❌    |
| /api/v1/notification                   |    ❌    |
| /api/v1/notification/:owner/:vendor_id |    ❌    |
| /api/v1/health                         |    ❌    |
| /api/v1/metrics                        |    ❌    |
