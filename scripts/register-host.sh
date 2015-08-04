#!/usr/bin/env bash

if [ -z "$FOREMAN_URL" ]; then
    echo "FOREMAN_URL missing"
    exit 1
fi

CURL_BASE="curl -k"

if ! [ -z "$FOREMAN_USER" ]; then
   CURL_BASE="$CURL_BASE -u $FOREMAN_USER:$FOREMAN_PASSWORD"
fi

foreman-curl() {
    FOREMAN_PATH=$1
    shift || :
    $CURL_BASE -H 'Content-Type: application/json' ${FOREMAN_URL}${FOREMAN_PATH} "$@"
}

foreman-status() {
    foreman-curl "$@" -s -o /dev/null -w '%{http_code}'
}

if [ "$1" = "foreman_check" ]; then
    status=$(foreman-status /api/v2/hosts)
    if ! [ "$status" = "200" ]; then
        echo "the foreman settings doesn't seem valid, expected http status 200, got $status"
        foreman-curl /api/v2/hosts
        exit 5
    else
        exit 0
    fi
fi

if [ -z "$HOST_NAME" ]; then
    echo "HOST_NAME missing"
    exit 1
fi

HOST_IP=${HOST_IP:-$(hostname -i)}

function create-host() {
    echo "creating host"
    foreman-curl /api/v2/hosts -X POST -d '{"host":{"name":"'$HOST_NAME'","managed":false,"interfaces_attributes":[{"ip":"'$HOST_IP'","primary":true}]}}'
}

function update-host() {
    echo "updating host"
    INTERFACE_ID=$(foreman-curl /api/v2/hosts/$HOST_NAME | sed 's/.*"interfaces":\[{"id":\([0-9]*\).*/\1/')
    if ! echo $INTERFACE_ID | grep -P '^[0-9]+$' > /dev/null; then
        echo "Could not get the interface id for update";
        exit 2
    fi
    foreman-curl /api/v2/hosts/$HOST_NAME -X PUT -d '{"host":{"interfaces_attributes":[{"id":"'$INTERFACE_ID'","ip":"'$HOST_IP'","primary":true}]}}'
}

host_details_status=$(foreman-status /api/v2/hosts/$HOST_NAME)

case "$host_details_status" in
    200)
    update-host
    ;;
    404)
    create-host
    ;;
    *)
    echo Unexpected http_code $host_details_status when checking host details
    ;;
esac
