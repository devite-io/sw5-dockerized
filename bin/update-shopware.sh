#!/bin/bash
cd "$(dirname "$0")"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <shopware container>"
  exit 1
fi

swContainer="$1"
swDir="/var/www/html"

# delete outdated caches
docker exec $swContainer bash -c "cd /usr/share/nginx/html && bin/console sw:cache:clear"

# update Shopware
docker exec --user nginx $swContainer bash -c "cd $swDir && php recovery/update/index.php --quiet"