#! /bin/sh

builds=$(echo '
9.6.3     9.6.3-r0
9.6       9.6.3-r0
9         9.6.3-r0
latest    9.6.3-r0
9.5.7     9.5.7-r0
9.5       9.5.7-r0
' | tr -s ' ')

IFS=$'\n'
for build in $builds; do
  tag=$(echo $build | cut -d ' ' -f 1 )
  pgVersion=$(echo $build | cut -d ' ' -f 2)
  
  echo docker build --tag bluedrop360/postgres-dump-to-s3:$tag --build-arg pg_version="$pgVersion" .
  eval docker build --tag bluedrop360/postgres-dump-to-s3:$tag --build-arg pg_version="$pgVersion" .
  echo docker push bluedrop360/postgres-dump-to-s3:$tag
  eval docker push bluedrop360/postgres-dump-to-s3:$tag
done
