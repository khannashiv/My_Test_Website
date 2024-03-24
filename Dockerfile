FROM ubuntu
RUN apt-get -y update
RUN apt-get install -y apache2
ADD . /var/www/html
CMD apachectl -D FOREGROUND
EXPOSE 80
