#!/usr/bin/env sh

#------------------------------------------------------------------------------------
# Loop over arguments
#------------------------------------------------------------------------------------
for arg in "$@"; do
    # [ -p | --package ]
    if [ -n "${package_flag}" ]; then
        package_flag=''
        package="${arg}"
    fi

    if [ "${arg}" = "-p" ] || [ "${arg}" = "--package" ]; then
        package_flag=true
    fi
done

#------------------------------------------------------------------------------------
# Exit on error
#------------------------------------------------------------------------------------
if [ -z "${package}" ]; then
  echo '> Package file not specified: [-p <FILE>, --package <FILE>]'
  exit 127
fi

if [ -f "./package/${package}.env" ]; then
  . "./package/${package}.env"
else
  echo "> Package file not found: './package/${package}.env'"
  exit 127
fi

builds=\
"${PG_FULL_VERSION}_${PG_FULL_VERSION}-r0_${ALPINE_VERSION}",\
"${PG_BASE_VERSION}_${PG_FULL_VERSION}-r0_${ALPINE_VERSION}"

if [ "${PG_LATEST:-'false'}" = 'true' ]; then
  builds="${builds}","latest_${PG_FULL_VERSION}-r0_${ALPINE_VERSION}"
fi

echo $builds | tr ',' '\n' | while read build; do
  ALPINE_VERSION=$(echo "${build}" | cut -d '_' -f 3)
  pg_dump_to_s3_tag=$(echo "${build}" | cut -d '_' -f 1 )
  PG_FULL_VERSION=$(echo "${build}" | cut -d '_' -f 2)

  echo ""
  echo "--------------------------------"
  echo "POSTGRES-DUMP-TO-S3 TAG: ${pg_dump_to_s3_tag}"
  echo "POSTGRES PACKAGE VERSION: ${PG_FULL_VERSION}"
  echo "--------------------------------"

  echo docker build --tag bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag --build-arg pg_full_version=$PG_FULL_VERSION --build-arg alpine_version="${ALPINE_VERSION}" .
  eval docker build --tag bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag --build-arg pg_full_version=$PG_FULL_VERSION --build-arg alpine_version="${ALPINE_VERSION}" . || exit 1
  echo docker push bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag
  eval docker push bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag || exit 1
done
