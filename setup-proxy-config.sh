#!/bin/bash -e

main() {
    generate_nginx_proxy_conf > /etc/nginx/conf.d/default.conf
    if should_force_dns_refresh; then
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
$(proxy_pass_line "$target")
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
should_force_dns_refresh() {
    if [ "$SHORT_DNS_TTL" = "yes" ]; then
        return 0
    else
        return 1
    fi
}
proxy_pass_line() {
    target="$1"

    if should_force_dns_refresh; then
cat << EOF
        set \$upstream "$target";
        proxy_pass \$upstream;
EOF
    else
cat << EOF
        proxy_pass $target;
EOF
    fi
}

bypass_dns_cache() {
    sed '
    /^\s*http {$/ a\
        resolver 127.0.0.11 1.1.1.1 8.8.8.8 valid=10s;  # Docker internal DNS\
        resolver_timeout 5s;\
    ' -i /etc/nginx/nginx.conf

    cat /etc/nginx/nginx.conf
}

main "$@"
