FROM nginx:1.11

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y -t jessie-backports certbot 
RUN echo "#!/bin/bash\ncertbot certonly -c /root/conf/cert.conf  -n --expand" > /etc/cron.d/certbot
