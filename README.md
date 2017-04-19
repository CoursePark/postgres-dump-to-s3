# postgres-dump-to-s3

Cron based database dump and upload to S3.

## Usage

Typically this image is instantiated as a container among many others and would have the responsibility of getting a database dump and uploading it to S3 at a particular time of day.

For instance: a production environment might back up its data every 4 hours to S3.

With a `docker-compose` set up, this might look like the following:

`docker-compose.prod.yml` defines a service:

```
  postgres-dump-to-s3:
    image: bluedrop360/postgres-dump-to-s3
    environment:
        PG_TO_S3_AWS_ACCESS_KEY_ID: ...
        PG_TO_S3_AWS_SECRET_ACCESS_KEY: ...
        PG_TO_S3_AWS_BUCKET: ...
        PG_TO_S3_AWS_OBJECT_APPEND: ...
        PG_TO_S3_AWS_OBJECT_PREPEND: ...
        PG_TO_S3_AWS_REGION: s3
        PG_TO_S3_CRON_HOUR: 1/4
        PG_TO_S3_CRON_MINUTE: 0
        PG_TO_S3_DATABASE_URL: postgres://...
    restart: always
```

`PG_TO_S3_AWS_OBJECT_APPEND` and/or `PG_TO_S3_AWS_OBJECT_PREPEND` can be used to create a non guessable name if it is desired to have the database dump files stored in a non password protected bucket *(without list permissions)*. For instance having a UUID such as `PG_TO_S3_AWS_OBJECT_APPEND: _5761d557-f50d-4338-8c7e-a87318b95f87` would result in an S3 object similar like `2017-04-19_21:00_5761d557-f50d-4338-8c7e-a87318b95f87` being created. Or use a slash in the prepend value for a similar effect of `5761d557-f50d-4338-8c7e-a87318b95f87/2017-04-19_21:00`.

***Note**: the usual cron tricks apply to the hour and minute env values. For instance setting `PG_TO_S3_CRON_HOUR` to `1/4` and `PG_TO_S3_CRON_MINUTE` to `0`, will trigger once every 4 hours.*
