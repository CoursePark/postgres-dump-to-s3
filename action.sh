#!/bin/sh

echo "postgres dump to s3 - getting a dump of database"
PGOPTIONS="-c statement_timeout=3600000" pg_dump -Fc --no-owner --clean -o $PG_TO_S3_DATABASE_URL > db.dump
echo "postgres dump to s3 - uploading to s3"
# S3 Upload using curl inspired by https://gist.github.com/chrismdp/6c6b6c825b07f680e710
now=$(date +"%Y-%m-%d_%H:%M")
date=$(date -R)
content_type="application/octet-stream"
object="/${PG_TO_S3_AWS_OBJECT_PREPEND}$now"
string="PUT\n\n$content_type\n$date\n/${PG_TO_S3_AWS_BUCKET}$object"
signature=$(echo -en "$string" | openssl sha1 -hmac "${PG_TO_S3_AWS_SECRET_ACCESS_KEY}" -binary | base64)
curl -X PUT -T db.dump \
    -H "Host: ${PG_TO_S3_AWS_BUCKET}.${PG_TO_S3_AWS_REGION}.amazonaws.com" \
    -H "Date: $date" \
    -H "Content-Type: $content_type" \
    -H "Authorization: AWS ${PG_TO_S3_AWS_ACCESS_KEY_ID}:$signature" \
    "https://${PG_TO_S3_AWS_BUCKET}.${PG_TO_S3_AWS_REGION}.amazonaws.com$object"
echo "postgres dump to s3 - complete"
