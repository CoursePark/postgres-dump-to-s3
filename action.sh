#!/bin/sh

echo "postgres dump to s3 - getting a dump of database"
PGOPTIONS="-c statement_timeout=3600000" pg_dump -Fc --no-owner --clean -o $PG_TO_S3_DATABASE_URL > db.dump
echo "postgres dump to s3 - uploading to s3"
now=$(date +"%Y-%m-%dT%H:%M")
object=${PG_TO_S3_AWS_OBJECT_PREPEND}${now}${PG_TO_S3_AWS_OBJECT_APPEND}.dump
export AWS_ACCESS_KEY_ID=$PG_TO_S3_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$PG_TO_S3_AWS_SECRET_ACCESS_KEY
aws --region ${PG_TO_S3_AWS_REGION} s3 cp db.dump s3://${PG_TO_S3_AWS_BUCKET}/$object
echo "postgres dump to s3 - complete"
