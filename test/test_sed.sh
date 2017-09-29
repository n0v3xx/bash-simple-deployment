#!/usr/bin/env bash

#VERSION='1.0.1'
#
#sed -i -r "s/DEPLOY.VERSION\b/$VERSION/g" sed/config.php
#echo "Replace Version finished"

FEATURE_VERSION_REPLACE=1
VERSION_PATTERN="DEPLOY.VERSION"
TAG="1.0.0"
PATH_VERSION_FILE="sed/config.php"

if test $FEATURE_VERSION_REPLACE == 1
then
    sed -i -r "s/$VERSION_PATTERN\b/$TAG/g" "$PATH_VERSION_FILE"
    echo "Replace Version finished"
fi