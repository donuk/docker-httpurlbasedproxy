#!/bin/bash -e

main() {
    generate_nginx_proxy_conf > /etc/nginx/conf.d/default.conf
    if [ "$SHORT_DNS_TTL" = "yes" ]; then
        bypass_dns_cache
    fi
}

list_redirects() {
    set | sed -n '/^PROXY_BACKEND\(_[0-9]\+\)\?=/ {s/[^=]*=//; s/:/ /; p;}' | sort -r
}

generate_nginx_proxy_conf() {
    cat <<EOF
server {
    listen       80 default;
EOF
    list_redirects | while read source target; do {
        cat <<EOF2
    location $source {
        proxy_pass $target;
        proxy_pass_request_headers on;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
EOF2
    }
    done

    cat <<EOF
}
EOF
}

bypass_dns_cache() {
    sed '
    /^\s*http {$/ a\
        resolver 127.0.0.11 valid=10s;  # Docker internal DNS\
        resolver_timeout 5s;\
    ' -i /etc/nginx/nginx.conf

    cat /etc/nginx/nginx.conf
}

main "$@"
