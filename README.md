# bash-simple-deployment
Simple bash deployment script for basic web projects.

## Required

* bash, git, php, rsync or scp
* Deploy Server
* Target Server

## Required directory structure

To make the deploy process simple as possible i recommend this directory structure on your server.

* Webserver
    * /var/www/project
        * /active - symlink to newest release
        * /releases - all deployed releases
            * /X.X.X - Releases
        

## Before you start

Modify the config values in /config/****.sh to your needs.

## Run deployment

Make it executable and then start the script.

    chmod +x run.sh
    ./run.sh