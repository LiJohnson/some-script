#!/bin/bash
#
# certbot renew manual-auth-hook
#
# by lcs
# 2020-10-15
# usage: <AccessKey ID> <AccessKey Secret>
# example: certbot --no-self-upgrade --cert-name=some_cert_name renew --manual-auth-hook="<script-path>/aliyun_dns.sh LTAI*********** L4u***********"

AliDDNS_AK="$1"
AliDDNS_SK="$2"

AliDDNS_TTL="600"

AliDDNS_DomainName=`echo -n $CERTBOT_DOMAIN | awk -F "." '{NF_1=NF-1; print $NF_1"."$NF}'`
AliDDNS_SubDomainName="${CERTBOT_DOMAIN/$AliDDNS_DomainName/}"

if [ "$AliDDNS_SubDomainName" = "" ];
then
    AliDDNS_SubDomainName="_acme-challenge"
else
    AliDDNS_SubDomainName="_acme-challenge.$AliDDNS_SubDomainName"
fi

# echo "AliDDNS_AK => $AliDDNS_AK"
# echo "AliDDNS_SK => $AliDDNS_SK"
# echo "CERTBOT_DOMAIN => $CERTBOT_DOMAIN"
# echo "CERTBOT_VALIDATION => $CERTBOT_VALIDATION"
# echo "AliDDNS_DomainName => $AliDDNS_DomainName"
# echo "AliDDNS_SubDomainName => $AliDDNS_SubDomainName"


timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`


urlencode() {
    out=""
    while read -n1 c
    do
        case $c in
            [a-zA-Z0-9._-]) out="$out$c" ;;
            *) out="$out`printf '%%%02X' "'$c"`" ;;
        esac
    done
    echo -n $out
}

enc() {
    echo -n "$1" | urlencode
}

get_recordid() {
    grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}

# usage: send_request <action> <args>
send_request() {
    local args="AccessKeyId=$AliDDNS_AK&Action=$1&Format=json&$2&Version=2015-01-09"
    local hash=$(echo -n "GET&%2F&$(enc "$args")" | openssl dgst -sha1 -hmac "$AliDDNS_SK&" -binary | openssl base64)
    curl -s "https://alidns.aliyuncs.com/?$args&Signature=$(enc "$hash")"
}

# usage: query_recordid <SubDomain>
query_recordid() {
    send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$1&Timestamp=$timestamp"
}
# usage: update_record <recordID> <value> <type>
update_record() {
    value="$2"
    type="$3"
    [ "$value" = "" ] && echo "no record value" && exit 1
    [ "$type" = "" ] && type="A"
    send_request "UpdateDomainRecord" "RR=$AliDDNS_SubDomainName&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$AliDDNS_TTL&Timestamp=$timestamp&Type=$type&Value=$value"
}

AliDDNS_RecordID=`query_recordid "$AliDDNS_SubDomainName.$AliDDNS_DomainName" | get_recordid`

update_record $AliDDNS_RecordID $CERTBOT_VALIDATION 'TXT'

sleep 1