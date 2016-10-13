#!/usr/bin/env bash

#########################################
################# General ###############
#########################################

# not needed at the moment
#G_WEBSERVER_USER="www-data"
#G_WEBSERVER_GROUP="www-data"

#########################################

# Method to sync the files to the target server
# rsync = faster | scp = slower
G_SYNC_MODE="rsync"