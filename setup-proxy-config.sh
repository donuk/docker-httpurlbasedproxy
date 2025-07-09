#!/bin/bash -e

main() {
    generate_nginx_proxy_conf > /etc/nginx/conf.d/default.conf
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
    }
EOF2
    }
    done

    cat <<EOF
}
EOF
}

main
