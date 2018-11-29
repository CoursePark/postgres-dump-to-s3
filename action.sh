#!/bin/sh

echo "postgres dump to s3 - getting a dump of the database"
tempFile=$(mktemp -u)
PGOPTIONS="-c statement_timeout=3600000" pg_dump -Fc --no-owner --clean -o $DATABASE_URL > $tempFile \
  || (echo "postgres dump to s3 - failed" && exit 1)
echo "postgres dump to s3 - uploading the dump file to s3"
if [ -n "${DUMP_OBJECT}" ]; then
  object=${DUMP_OBJECT}
else
  now=$(date +"%Y-%m-%dT%H:%M")
  object=${DUMP_OBJECT_PREFIX}${now}.dump
fi
echo postgres dump to s3 - uploading s3://${AWS_BUCKET}/$object
bucketEncrypt="$(aws s3api get-bucket-encryption --bucket ${AWS_BUCKET})"
if [ -n "${bucketEncrypt}" ]; then
  sse="$(echo ${bucketEncrypt} | jq '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault')"
  if echo ${sse} | jq -e '.KMSMasterKeyID' > /dev/null; then
    kmMasterKeyId="$(echo ${sse} | jq -j '.KMSMasterKeyID')"
    kmsKey="$(aws --region ${AWS_REGION} kms describe-key --key-id ${kmMasterKeyId})"
    sseArgs="--sse aws:kms --sse-kms-key-id $(echo ${kmsKey} | jq -j '.KeyMetadata.Arn')"
  else
    sseArgs="--sse AES256"
  fi
fi
eval aws --only-show-errors --region ${AWS_REGION} s3 cp $sseArgs $tempFile s3://${AWS_BUCKET}/$object
rm $tempFile
echo "postgres dump to s3 - complete"
