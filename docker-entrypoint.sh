#!/bin/sh

set -e

echo "> Copying settings"
cp -rf /data/projects/dknr-verisure/package.json /data/package.json
cp -rf /data/projects/dknr-verisure/data/settings.js /data/settings.js
cp -rf /data/projects/dknr-verisure/data/.config.projects.json /data/.config.projects.json
cp -rf /data/projects/dknr-verisure/data/admin.png /data/admin.png
echo "> Preparing credentials"
cd /data
sed -i -e "s|DKNR_USERNAME|${DKNR_USERNAME}|g" settings.js
sed -i -e "s|DKNR_HASH|$(expr substr "$(echo "${DKNR_PASSWORD}" | node-red admin hash-pw)" 11 100)|g" settings.js
sed -i -e "s|DKNR_SECRET|${DKNR_SECRET}|g" settings.js
echo "> Instaling packages"
npm install --unsafe-perm --no-update-notifier --no-fund --omit=dev
echo "> Running node-red"
cd /usr/src/node-red
/usr/src/node-red/entrypoint.sh node-red