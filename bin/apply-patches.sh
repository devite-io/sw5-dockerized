#!/bin/bash
cd "$(dirname "$0")"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <shopware container>"
  exit 1
fi

swContainer="$1"
swDir="/var/www/html"

docker cp ../patches/. $swContainer:$swDir/engine/Shopware/
docker exec $swContainer bash -c "cd $swDir/engine/Shopware && chown -R www-data:www-data . && chmod -R 755 ."