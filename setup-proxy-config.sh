#!/bin/bash -e

main() {
    generate_nginx_proxy_conf > /etc/nginx/conf.d/default.conf
    cat /etc/nginx/conf.d/default.conf
}

list_redirects() {
    set | sed -n '/^PROXY_BACKEND\(_[0-9]\+\)\?=/ {s/[^=]*=//; s/:/ /; p;}' | sort -r
}

# Split a target URL like "http://api:3000/graphql/" into its
# scheme+host part ("http://api:3000") and its path part ("/graphql/").
# If no path is present, the path defaults to "/".
split_target() {
    local target="$1"
    if [[ $target =~ ^([a-zA-Z][a-zA-Z0-9+.-]*://[^/]+)(/.*)?$ ]]; then
        target_host="${BASH_REMATCH[1]}"
        target_path="${BASH_REMATCH[2]:-/}"
    else
        target_host="$target"
        target_path="/"
    fi
}

generate_nginx_proxy_conf() {
    local resolver_valid="${RESOLVER_TIMEOUT:-10s}"
    cat <<EOF
server {
    listen       80 default;
    resolver 127.0.0.11 valid=$resolver_valid;

EOF
    list_redirects | while read source target; do {
        split_target "$target"

        cat <<EOF2
    location $source {
EOF2
        if [ "$source" != "$target_path" ]; then
            cat <<EOF3
        rewrite ^$source(.*)\$ $target_path\$1 break;
EOF3
        fi
        cat <<EOF4
        set \$upstream $target_host;
        proxy_pass \$upstream;
        proxy_pass_request_headers on;
        proxy_set_header Host \$host;
        proxy_connect_timeout $TIMEOUT;
        proxy_send_timeout $TIMEOUT;
        proxy_read_timeout $TIMEOUT;
        send_timeout $TIMEOUT;
    }
EOF4
    }
    done

    cat <<EOF
}
EOF
}

main
