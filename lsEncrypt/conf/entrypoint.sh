#!/bin/sh

if test -d  "/etc/letsencrypt/live/$DOMAIN" 
then
	echo "Already Get Certfication Files"
else
	echo "Try to Get Certification Files"
	certbot certonly  --agree-tos --standalone-supported-challenges http-01 --standalone -n -d $DOMAIN  -m $MAIL
	if [ $? -ne 0 ]
	then
		echo "Failed to Get Cirtification Files"
		exit 1
	fi
fi
nginx -c /root/conf/nginx.conf -g "daemon off;"
