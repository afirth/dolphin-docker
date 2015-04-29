FROM ubuntu:latest
 
MAINTAINER Alper Kucukural <alper.kucukural@umassmed.edu>
 
RUN apt-get update
RUN apt-get -y upgrade
 
# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysqlnd php5-gd php-pear php-apc php5-curl curl lynx-cur mysql-server libreadline-dev libsqlite3-dev libbz2-dev libssl-dev python python-dev libmysqlclient-dev python-pip

RUN pip install MySQL-python


# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite
 
# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini
 
# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV DOLPHIN_TOOLS_PATH=/usr/local/share/dolphin_tools
 
EXPOSE 80
EXPOSE 3306


# Copy site into place.
ADD dolphin_ui /var/www/html/dolphin
ADD dolphin_webservice /var/www/html/dolphin_webservice
ADD bin  /usr/local/bin
ADD dolphin_tools ${DOLPHIN_TOOLS_PATH}
ADD genome_data /tmp/genome_data

RUN cd /usr/local/bin/dolphin_bin/ZSI-2.1-a1 && python setup.py install

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

RUN echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
RUN a2enconf fqdn
RUN echo "export DOLPHIN_TOOLS_PATH="${DOLPHIN_TOOLS_PATH} /etc/apache2/envvars



