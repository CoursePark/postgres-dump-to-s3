#! /bin/sh

builds=$(echo '
9.6.3     9.6.3-r0    v3.6
9.6       9.6.3-r0    v3.6
9         9.6.3-r0    v3.6
latest    9.6.3-r0    v3.6
9.5.7     9.5.7-r0    v3.4
9.5       9.5.7-r0    v3.4
' | tr -s ' ')

IFS=$'\n'
for build in $builds; do
  tag=$(echo $build | cut -d ' ' -f 1 )
  pgVersion=$(echo $build | cut -d ' ' -f 2)
  pgAlpineBranch=$(echo $build | cut -d ' ' -f 3)
  
  echo docker build --tag bluedrop360/postgres-dump-to-s3:$tag --build-arg pg_version="$pgVersion" --build-arg pg_alpine_branch=$pgAlpineBranch .
  eval docker build --tag bluedrop360/postgres-dump-to-s3:$tag --build-arg pg_version="$pgVersion" --build-arg pg_alpine_branch=$pgAlpineBranch .
  echo docker push bluedrop360/postgres-dump-to-s3:$tag
  eval docker push bluedrop360/postgres-dump-to-s3:$tag
done
