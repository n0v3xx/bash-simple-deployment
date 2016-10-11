#!/usr/bin/env bash

#########################################
############## Config ###################
#########################################

# include config
# base path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include different configs
source $DIR/config/general.config.sh
source $DIR/config/git.config.sh
source $DIR/config/path.config.sh
source $DIR/config/composer.config.sh
source $DIR/config/server.config.sh