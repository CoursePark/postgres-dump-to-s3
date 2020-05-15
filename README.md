# postgres-dump-to-s3

Cron based database dump and upload to S3.

## Build

`./build_push.sh [-p <FILE>, --package <FILE>]`

`./build_push.sh -p 11.7-3.9`

### Package files

Each package file represents a release for a particular `postgres` branch.

The contents of the latest package file may look like this:

```
ALPINE_VERSION='3.9'
PG_BASE_VERSION='11'
PG_FULL_VERSION='11.7'
PG_LATEST=true
```

## Usage

Typically this image is instantiated as a container among many others and would have the responsibility of getting a database dump and uploading it to S3 at a particular time of day.

For instance: a production environment might back up its data every 4 hours to S3.

With a `docker-compose` set up, this might look like the following:

`docker-compose.prod.yml` defines a service:

```
  postgres-dump-to-s3:
    image: bluedrop360/postgres-dump-to-s3
    environment:
        AWS_ACCESS_KEY_ID: ...
        AWS_SECRET_ACCESS_KEY: ...
        AWS_BUCKET: ...
        DUMP_OBJECT_PREFIX: ...
        AWS_REGION: s3
        CRON_HOUR: */4
        CRON_MINUTE: 0
        DATABASE_URL: postgres://...
    restart: always
```

`DUMP_OBJECT_PREFIX` can be used to create a non guessable name if it is desired to have the database dump files stored in a non password protected bucket *(without list permissions)*. For instance having a UUID such as `DUMP_OBJECT_PREFIX: 5761d557-f50d-4338-8c7e-a87318b95f87/` would result in an S3 object similar like `5761d557-f50d-4338-8c7e-a87318b95f87/2017-04-19T21:00`.

***Note**: the usual cron tricks apply to the hour and minute env values. For instance setting `CRON_HOUR` to `*/4` and `CRON_MINUTE` to `0`, will trigger once every 4 hours.*

Pruning the backups can be done with the `bluedrop360/s3-objects-prune` repo.

Restoring from a backup can be done with the `bluedrop360/postgres-restore-from-s3` repo.
