#!/bin/bash

source /root/vars.env

CHECK=$(printf '\U2705')
CROSS=$(printf '\U274c')

s3cmd put -r /var/backup/db/latest s3://mysql-backup-persistent

# Send status to telegram
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ];
then
  MESSAGE="${CHECK} MySQL weekly persistent backup uploaded successfully"
else
  MESSAGE="${CROSS} ERROR: MySQL weekly persistent backup upload failed with exit code ${EXIT_CODE}"
fi

curl -X POST \
  -H 'Content-Type: application/json' \
  -d "{\"chat_id\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"${MESSAGE}\"}" \
  https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage > /dev/null