#!/usr/bin/env bash

#########################################
################# Path ##################
#########################################

PATH_PROJECT="/var/www/project"
PATH_PHING="vendor/bin/phing"
PATH_BUILD="build/"
PATH_TAGS="tags/"
PATH_TMP="tmp/"

# Folder they custom  chmod
PATH_CHMOD_VALUE=777
# array syntax (test test2 test3)
PATH_CHMOD_ARRAY=(data/*)