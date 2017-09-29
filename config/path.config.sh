#!/usr/bin/env bash

#########################################
################# Path ##################
#########################################

PATH_PHING="vendor/bin/phing"
PATH_BUILD="build/"
PATH_TAGS="tags/"

# if enable the version will be set (0 = disable)
FEATURE_VERSION_REPLACE=0
VERSION_PATTERN="DEPLOY.VERSION"
PATH_VERSION_FILE="config/autoload/global.php"

# enable or disable the custom chmod feature 0 = disabled
CUSTOM_CHMOD=0
# Folder they need custom chmod e.g. cache
PATH_CHMOD_VALUE=777
# array syntax (test test2 test3)
PATH_CHMOD_ARRAY=(data/*)

# enable or disable the clear feature 0 = disabled
CLEAR_CACHE=0
# array syntax (test test2 test3)
PATH_CLEAR_CACHE_ARRAY=(data/cache/*)