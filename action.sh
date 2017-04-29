#!/bin/sh

echo "postgres dump to s3 - getting a dump of database"
PGOPTIONS="-c statement_timeout=3600000" pg_dump -Fc --no-owner --clean -o $DATABASE_URL > db.dump
echo "postgres dump to s3 - uploading to s3"
now=$(date +"%Y-%m-%dT%H:%M")
object=${DUMP_OBJECT_PREFIX}${now}.dump
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
aws --region ${AWS_REGION} s3 cp db.dump s3://${AWS_BUCKET}/$object
echo "postgres dump to s3 - complete"
