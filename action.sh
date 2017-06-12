#!/bin/sh

echo "postgres dump to s3 - getting a dump of the database"
PGOPTIONS="-c statement_timeout=3600000" pg_dump -Fc --no-owner --clean -o $DATABASE_URL > db.dump
echo "postgres dump to s3 - uploading the dump file to s3"
if [ -n "${DUMP_OBJECT}" ]; then
  object=${DUMP_OBJECT}
else
  now=$(date +"%Y-%m-%dT%H:%M")
  object=${DUMP_OBJECT_PREFIX}${now}.dump
fi
aws --region ${AWS_REGION} s3 cp db.dump s3://${AWS_BUCKET}/$object
echo "postgres dump to s3 - complete"
