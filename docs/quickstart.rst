*********
Quick Start Guide
*********

This guide will walk you through how to starty using dolphin workflows.


General
===========

Clone the docker first:
https://github.com/UMMS-Biocore/dolphin-docker

Building dolphin-docker
================

First we need to build dolphin-docker image. 
Please go to the cloned directory.

cd your_path/dolphin-docker
docker build -t dolphin-docker .

Creating an export directory in your host
================

dolphin-docker uses a directory in your host system to hold information when you exit your docker container.
If you are using boot2docker please connect your VM with

boot2docker ssh

create your export directory and give the full permissions that are going to be used by the container.

mkdir /mnt/sda1/export
chmod 777 /mnt/sda1/export

Running dolphin-docker
================

Dolphin docker has a apache web server that will be used on port 8080 if you run like below. 

docker run -p 8080:80 -v /mnt/sda1/export:/export -ti dolphin-docker /bin/bash

Initialize the system 
================

You need to initialize the system using 'startup' command.
This will prepare example genome and mysql database in /export directory that are going to be used by dolphin in the first run.  

Starting mysql and web server
================

'startup' command will also start mysql and apache web servers.
When you run dolphin-docker container. You need to start start using this command.

To reach the applications on apache server please add your docker host ip address into /etc/hosts file 

Ex:
-----------------
echo ${DOCKER_HOST} 

tcp://192.168.59.103:2376

/etc/hosts =>

192.168.59.103	 dolphin.umassmed.edu

Now you can use your browser to reach the website using

* http://dolphin.umassmed.edu:8080/dolphin

For phpmyadmin

* http://dolphin.umassmed.edu:8080/phpmyadmin

Running a test workflow
================

To run a test workflow please go to directory below;

cd /usr/local/share/dolphin_tools/test/

./run.bash w1.txt




















