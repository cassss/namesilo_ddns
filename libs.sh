#!/bin/sh

NAMESILO_LIST="https://www.namesilo.com/api/dnsListRecords?version=1&type=xml"
NAMESILO_CREATE="https://www.namesilo.com/api/dnsAddRecord?version=1&type=xml"
NAMESILO_UPDATE="https://www.namesilo.com/api/dnsUpdateRecord?version=1&type=xml"
IP6_SERVER="https://api64.ipify.org"
IP4_SERVER="https://api64.ipify.org"

GetIP() {
    if [[ $1 == "A" ]]
    then 
        curl -s $IP4_SERVER
    else
        curl -s $IP6_SERVER
    fi
}

# key domain
GetDNSList() {
    curl -s "$NAMESILO_LIST&key=$1&domain=$2"
}

# key domain rrtype rrhost rrvalue rrttl=3600
CreateDNSRecord() {
    key=$1
    domain=$2
    rrtype=$3
    rrhost=$4
    rrvalue=$5
    rrttl=$6
    [[ "$rrttl" == "" ]] && ttl="3600"
    url="$NAMESILO_CREATE&key=$key&domain=$domain&rrtype=$rrtype&rrhost=$rrhost&rrvalue=$rrvalue&rrttl=$rrttl"
    curl -s $url | xmllint --xpath "/namesilo/reply/detail/text()" -
}

# key domain rrid rrtype rrhost rrvalue rrttl=3600
UpdateDNSRecord() {
    key=$1
    domain=$2
    rrid=$3
    rrtype=$4
    rrhost=$5
    rrvalue=$6
    rrttl=$7
    [[ "$rrttl" == "" ]] && ttl="3600"
    url="$NAMESILO_UPDATE&key=$key&domain=$domain&rrid=$rrid&rrhost=$rrhost&rrvalue=$rrvalue&rrttl=$rrttl"
    curl -s $url | xmllint --xpath "/namesilo/reply/detail/text()" -
}

# key domain host type
GetRecord() {
    list=`GetDNSList $1 $2`
    query="/namesilo/reply/resource_record[host='$3.$2' and type='$4']"
    echo $list | xmllint --xpath "$query" -
}

# record value
CheckNeedUpdate() {
    echo $1 | xmllint --xpath "/resource_record[value!='$2']/record_id/text()" -
}