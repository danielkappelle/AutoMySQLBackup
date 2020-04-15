#!/bin/bash

source /root/vars.env

# Perform rotated backup
/usr/local/bin/automysqlbackup /etc/automysqlbackup/myserver.conf

CHECK=$(printf '\U2705')
CROSS=$(printf '\U274c')


# Send status to telegram
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ];
then
  MESSAGE="${CHECK} MySQL backup successful"
else
  MESSAGE="${CROSS} ERROR: MySQL backup failed with exit code ${EXIT_CODE}"
fi

curl -X POST \
  -H 'Content-Type: application/json' \
  -d "{\"chat_id\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"${MESSAGE}\"}" \
  https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage > /dev/null

s3cmd sync -r --delete-removed /var/backup/db s3://mysql-backup

# Send status to telegram
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ];
then
  MESSAGE="${CHECK} MySQL backup synced successfully"
else
  MESSAGE="${CROSS} ERROR: MySQL backup sync failed with exit code ${EXIT_CODE}"
fi

curl -X POST \
  -H 'Content-Type: application/json' \
  -d "{\"chat_id\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"${MESSAGE}\"}" \
  https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage > /dev/null