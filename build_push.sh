#!/usr/bin/env sh

alpine_version='3.8'
legacy_image=false
pg_major_version='10'
pg_package_version='10.10'

builds=\
"${pg_package_version}_${pg_package_version}-r0_${alpine_version}",\
"${pg_major_version}_${pg_package_version}-r0_${alpine_version}"

if [ "${legacy_image}" = 'false' ]; then
  builds="${builds}","latest_${pg_package_version}-r0_${alpine_version}"
fi

echo $builds | tr ',' '\n' | while read build; do
  alpine_version=$(echo "${build}" | cut -d '_' -f 3)
  pg_dump_to_s3_tag=$(echo "${build}" | cut -d '_' -f 1 )
  pg_package_version=$(echo "${build}" | cut -d '_' -f 2)

  echo ""
  echo "--------------------------------"
  echo "POSTGRES-DUMP-TO-S3 TAG: ${pg_dump_to_s3_tag}"
  echo "POSTGRES PACKAGE VERSION: ${pg_package_version}"
  echo "--------------------------------"

  echo docker build --tag bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag --build-arg pg_package_version=$pg_package_version --build-arg alpine_version="${alpine_version}" .
  eval docker build --tag bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag --build-arg pg_package_version=$pg_package_version --build-arg alpine_version="${alpine_version}" . || exit 1
  echo docker push bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag
  eval docker push bluedrop360/postgres-dump-to-s3:$pg_dump_to_s3_tag || exit 1
done
