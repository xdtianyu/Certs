#!/bin/bash

bucket="$1"
file="$2"
resource="/${bucket}/${file}"
contentType="text/plain"
dateValue="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"

if [ "$3" == "-d" ]; then
    PARAMS=""
    stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}"
else
    PARAMS="-X PUT -T ${file}"
    stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
fi

signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${MINIO_SECRET_KEY} -binary | base64`

curl -k ${PARAMS} \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${MINIO_ACCESS_KEY}:${signature}" \
  $S3_URL/${bucket}/${file}
