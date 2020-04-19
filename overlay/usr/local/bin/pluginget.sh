#!/bin/sh
logger -t pluginget "Reading $1"

# Get configuration settings directly from config files, some recursively.

case $1 in
    httpport)
	# If multiple non-SSL ports are configured, return the first one only
	# xargs and printf used to ensure no newline at the end, which would
	# otherwise confuse iocage's adminportal placeholder substitutions
        sed -En -e '/listen/Is/listen[[:blank:]]*([[:digit:]]+)[[:blank:]]*;/\1/Ip;' \
            /usr/local/etc/nginx/conf.d/zoneminder.conf | head -n 1 | xargs -0 printf "%s"
        ;;
    httpsport)
	# If multiple SSL ports are configured, return the first one only
        sed -En -e '/listen/Is/listen[[:blank:]]*([[:digit:]]+)[[:blank:]]*ssl[[:blank:]]*;/\1/Ip;' \
            /usr/local/etc/nginx/conf.d/zoneminder.conf | head -n 1 | xargs -0 printf "%s"
        ;;
    sslcert)
	# If multiple certificates have been set, return the last one
        sed -En -e '/ssl_certificate/Is/ssl_certificate[[:blank:]]*([^; ]+)[[:blank:]]*;/\1/Ip;' \
            /usr/local/etc/nginx/conf.d/zoneminder.conf | tail -n 1 | xargs -0 printf "%s"
        ;;
    sslkey)
	# If multiple private key files have been set, return the last one
        sed -En -e '/ssl_certificate_key/Is/ssl_certificate_key[[:blank:]]*([^; ]+)[[:blank:]]*;/\1/Ip;' \
            /usr/local/etc/nginx/conf.d/zoneminder.conf | tail -n 1 | xargs -0 printf "%s"
        ;;
    adminprotocol)
        if [ "$(pluginget.sh httpsport)" -a -e "$(pluginget.sh sslcert)" -a -e "$(pluginget.sh sslkey)" ]; then
            printf "https"
        else
            printf "http"
        fi
        ;;
    adminport)
        if [ "$(pluginget.sh httpsport)" -a -e "$(pluginget.sh sslcert)" -a -e "$(pluginget.sh sslkey)" ]; then
            printf "$(pluginget.sh httpsport)"
        else
            printf "$(pluginget.sh httpport)"
        fi
        ;;
    *)
        echo "Unknown option">&2
        exit 1
        ;;
esac
