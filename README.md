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
        PG_TO_S3_AWS_OBJECT_PREPEND: ...
        PG_TO_S3_AWS_REGION: s3-us-east-1
        PG_TO_S3_CRON_HOUR: 1/4
        PG_TO_S3_CRON_MINUTE: 0
        PG_TO_S3_DATABASE_URL: postgres://...
    restart: always
```

***Note**: the usual cron tricks apply to the hour and minute env values. For instance setting `PG_TO_S3_CRON_HOUR` to `1/4` and `PG_TO_S3_CRON_MINUTE` to `0`, will trigger once every 4 hours.*
