#!/usr/bin/env bash

#########################################
################# Server ################
#########################################

SERVER_IP="<IP-Adress>"
SERVER_USER="root"

SERVER_WEBSERVER_USER="www-data"
SERVER_WEBSERVER_GROUP="www-data"

SERVER_PATH_LOG="/srv/test/log"
SERVER_PATH_TAGS="/srv/test/releases"
SERVER_PATH_ACTIVE="/srv/test/active"

# name of your public directory in your project
SERVER_FOLDER_WWW="public"

# enable log folder symlinking
LOG_SYMLINKING=0
# relative to project root
SERVER_FOLDER_LOG="data/log"