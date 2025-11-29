#!/bin/bash
cd "$(dirname "$0")"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <shopware container>"
  exit 1
fi

swContainer="$1"
swDir="/var/www/html"

# install Shopware
docker exec -u www-data $swContainer bash -c "cd $swDir && php recovery/install/index.php --quiet --no-skip-import \
  --shop-host='127.0.0.1:8080' --shop-locale='de_DE' --admin-locale='de_DE' --shop-currency='EUR' \
  --admin-name='Administrator' --admin-email='admin@example.com' --admin-username='admin' --admin-password='shopware' \
  --db-host='database' --db-user='root' --db-password='password' --db-name='shopware'"
docker exec -u www-data $swContainer bash -c "cd $swDir && cp config.default.php config.php"
docker container restart $swContainer

# disable first run wizard
docker exec -u www-data $swContainer bash -c "cd $swDir && php bin/console sw:firstrunwizard:disable"

# apply patches
bash ./apply-patches.sh $swContainer