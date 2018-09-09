#!/bin/bash

mkdir -p ~/.ssh
chmod 700 ~/.ssh

wget $KEYS_URL/config -O ~/.ssh/config
wget $KEYS_URL/known_hosts -O ~/.ssh/known_hosts

for file in $(find hosts -type f) ; do
    DIRS=() && REMOTE_CMD="" && . "$file"

    if [ -z "$DIRS" ]; then
        echo "# DIRS is not configured, ignore $file."
        continue
    fi

    host=$(basename $file)
    for conf in "${DIRS[@]}"; do
        DIR="" && . "sites/$conf.conf"
        if [ -z "$DIR" ]; then
            echo "# DIR is not configured, ignore $conf."
            continue
        fi
        echo "# $file: copy $DIR --> $host"
        mkdir -p dist/$host/le/certs/$DIR/
        cp certs/$DIR/fullchain.pem dist/$host/le/certs/$DIR/
        cp certs/$DIR/privkey.pem dist/$host/le/certs/$DIR/
    done

    tar czf dist/$host.tar.gz -C dist/$host/ le
    scp dist/$host.tar.gz $host:
    echo "# $file: $host --> $REMOTE_CMD"
    ssh $host "
        mkdir -p /etc/nginx/
        [ -e /etc/nginx/le ] && rm -r /etc/nginx/le
        tar xzf $host.tar.gz -C /etc/nginx/ --warning=no-timestamp
        rm \"$host.tar.gz\"
        $REMOTE_CMD
    "
done
