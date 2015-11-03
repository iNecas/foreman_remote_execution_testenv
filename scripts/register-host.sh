#!/usr/bin/env bash
set -x

if [ -z "$FOREMAN_URL" ]; then
    echo "FOREMAN_URL missing"
    exit 1
fi

if [ -z "$PROXY_URL" ]; then
    echo "PROXY_URL missing"
    exit 1
fi

FOREMAN_CURL_BASE="curl -k"
PROXY_CURL_BASE="curl -k"

if ! [ -z "$FOREMAN_USER" ]; then
   FOREMAN_CURL_BASE="$FOREMAN_CURL_BASE -u $FOREMAN_USER:$FOREMAN_PASSWORD"
fi

foreman-curl() {
    FOREMAN_PATH=$1
    shift || :
    $FOREMAN_CURL_BASE -H 'Content-Type: application/json' ${FOREMAN_URL}${FOREMAN_PATH} "$@"
}

foreman-status() {
    foreman-curl "$@" -s -o /dev/null -w '%{http_code}'
}

proxy-curl() {
    PROXY_PATH=$1
    shift || :
    $PROXY_CURL_BASE -H 'Content-Type: application/json' ${PROXY_URL}${PROXY_PATH} "$@"
}

if [ "$1" = "check" ]; then
    status=$(foreman-status /api/v2/hosts)
    if ! [ "$status" = "200" ]; then
        echo "the foreman settings doesn't seem valid, expected http status 200, got $status"
        foreman-curl /api/v2/hosts
        exit 5
    fi

    proxy_features=$(proxy-curl /features)
    if ! echo $proxy_features | grep ssh > /dev/null; then
        echo "The proxy doesn't support the ssh feature: ${proxy_features}"
        exit 6
    fi
    exit 0
fi

function exchange-keys() {
    PROXY_PUBKEY=~/.ssh/id_rsa_foreman_proxy.pub
    proxy-curl /ssh/pubkey > $PROXY_PUBKEY
    if ! fgrep "$(cat $PROXY_PUBKEY)" ~/.ssh/authorized_keys; then
        echo adding $PROXY_PUBKEY to authorized keys
        cat $PROXY_PUBKEY >> ~/.ssh/authorized_keys
    fi

    CLIENT_PUBKEY=$(cat /etc/ssh/ssh_host_rsa_key.pub)
    CLIENT_PUBKEY_PARAM="ssh_pubkey"
    CLIENT_PUBKEY_PARAM_ID=$(foreman-curl /api/v2/hosts/$HOST_NAME | grep -o '"id":[0-9],"name":"'$CLIENT_PUBKEY_PARAM'"' | grep -o '[0-9]*')
    foreman-curl /api/v2/hosts/$HOST_NAME -X PUT -d '{"host":{"host_parameters_attributes":[{"id":"'$CLIENT_PUBKEY_PARAM_ID'","name":"'$CLIENT_PUBKEY_PARAM'","value":"'"$CLIENT_PUBKEY"'"}]}}'
}

if [ -z "$HOST_NAME" ]; then
    echo "HOST_NAME missing"
    exit 1
fi

#host_details_status=$(foreman-status /api/v2/hosts/$HOST_NAME)
#
#case "$host_details_status" in
#    200)
#    update-host
#    ;;
#    404)
#    create-host
#    ;;
#    *)
#    echo Unexpected http_code $host_details_status when checking host details
#    ;;
#esac

echo "uploading facts"
`/upload_facts.rb`

exchange-keys
