#!/usr/bin/env bash

#########################################
################# Path ##################
#########################################

PATH_PHING="vendor/bin/phing"
PATH_BUILD="build/"
PATH_TAGS="tags/"

# Folder they need custom chmod e.g. cache
PATH_CHMOD_VALUE=777
# array syntax (test test2 test3)
PATH_CHMOD_ARRAY=(data/*)