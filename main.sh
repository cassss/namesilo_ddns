#!/bin/bash
API_KEY=$1
DOMAIN=$2
HOST=$3
TYPE=$4
TTL=$5

source libs.sh

echo ""
echo "sync start：`date`"

[[ "$API_KEY" == "" ]] && echo "api_key is empty" && exit 1
[[ "$DOMAIN" == "" ]] && echo "domain is empty" && exit 1
[[ "$HOST" == "" ]] && echo "host is empty" && exit 1
[[ "$TYPE" == "" ]] && echo "type is empty" && exit 1
[[ "$TYPE" == "" ]] && echo "type is empty" && exit 1
[[ "`which xmllint`" == "" ]] && echo "need xmllint" && exit 1
[[ "`which curl`" == "" ]] && echo "need curl" && exit 1

loc_ip="`GetIP $TYPE`"
if [[ $loc_ip == "" ]]
then
    echo "cant get ip"
    exit 1
fi

echo "now ip is $loc_ip"

record=`GetRecord $API_KEY $DOMAIN $HOST $TYPE`

if [[ $record == "" ]]
then
    echo "not found dns record, start try to create"
    # key domain type host value ttl=3600
    echo "create response：`CreateDNSRecord $API_KEY $DOMAIN $TYPE $HOST $loc_ip`"
    exit
fi

echo "found dns record, check ip"

record_id=`CheckNeedUpdate "$record" $loc_ip`
if [[ "$record_id" == "" ]]
then
    echo "dont need update"
    exit
fi

echo "start update：recourd_id：$record_id ip: $loc_ip"
# key domain rrid rrtype rrhost rrvalue rrttl=3600
echo "update response：`UpdateDNSRecord $API_KEY $DOMAIN $record_id $TYPE $HOST $loc_ip`"


