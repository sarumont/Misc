#!/bin/bash

IP=`curl --ipv4 -s http://icanhazip.com/`
curl -s \
     -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -X "PATCH" \
     -i "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT/zones/$ZONE_ID/records/$RECORD_ID" \
     -d "{\"content\":\"$IP\"}"
