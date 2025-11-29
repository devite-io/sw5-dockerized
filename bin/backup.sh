#!/bin/bash

if [ $# -lt 3 ]; then
  echo "Usage: $0 <shopware container> <db container> <db password>"
  exit 1
fi


### BEGIN VALIDATION ###

swContainer="$1"
dbContainer="$2"
sqlPassword="$3"

host="localhost"
port="3306"
user="root"

(docker exec $dbContainer mariadb \
  -h "$host" \
  -P "$port" \
  -u "$user" \
  -p"$sqlPassword" \
  -e "SELECT 1;" \
) >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Database authentication failed."
  exit 1
fi


### BEGIN BACKUP ###

timestamp="$(date '+%Y-%m-%d_%H-%M-%S')"
mkdir backup-$timestamp && cd backup-$timestamp

# backup database
{
  (docker exec $dbContainer mariadb-dump \
    -h "$host" \
    -P "$port" \
    -u "$user" \
    -p"$sqlPassword" \
    --add-drop-table \
    --ignore-table-data "shopware.s_core_log" \
    --lock-all-tables \
    --hex-blob \
    --disable-comments \
    shopware \
  )
} > shopware-db.sql

# backup Shopware
mkdir shopware-files && cd shopware-files

containerPath="$swContainer:/var/www/html"

docker cp -q "$containerPath/custom/" custom
docker cp -q "$containerPath/files/" files
docker cp -q "$containerPath/media/" media && rm -rf media/.htaccess
docker cp -q "$containerPath/public/" public
mkdir -p themes
docker cp -q "$containerPath/themes/Backend/" themes/Backend
docker cp -q "$containerPath/themes/Frontend/" themes/Frontend
docker cp -q "$containerPath/var/" var && rm -rf var/log var/cache
docker cp -q "$containerPath/web/" web && rm -rf web/cache
docker cp -q "$containerPath/config.php" ./
docker cp -q "$containerPath/.htaccess" ./
docker cp -q "$containerPath/.htpasswd" ./

cd ../

# compress backup
cd ../
tar -czf $timestamp.tar.gz backup-$timestamp/
rm -r backup-$timestamp/