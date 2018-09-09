#!/bin/bash

export ALWAYS_CREATE_DOMAIN=true

wget https://github.com/xdtianyu/scripts/raw/master/le-dns/le-cloudflare.sh
chmod +x le-cloudflare.sh

cd sites

for file in ./*.conf ;do
    ../le-cloudflare.sh "$file";
done

mv certs ../
mv accounts ../certs
