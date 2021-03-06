#!/usr/bin/env bash

# include config
source config.sh

# Installation
echo "Willkommen zum deployment deines Projektes"
read -p "Möchten Sie den deploy Prozess starten? (y) " startDeploy

if [ "$startDeploy" = "y" ]
    then
        ############################# create tags folder #################################
        if [ -d ${PATH_TAGS} ]
            then
                cd ${PATH_TAGS}
            else
                mkdir ${PATH_TAGS}
                cd ${PATH_TAGS}
        fi

        ############################# create tag folder #################################
        read -p "Erstelle Tag Ordner (z.B. 1.0.0): " TAG
        mkdir $TAG
        cd $TAG

        ############################# checkout from git #################################
        read -p "Checkout Tag (z.B. 1.0.0) (default: master): " GITTAG
        if [ "$GITTAG" == ${GIT_DEFAULT_BRANCH} ]
            then
                # github swtich
                if test $GIT_GITHUB_SWITCH == 1
                then
                    git clone --progress ${GIT_REMOTEHOST_SSH} ${GIT_DEFAULT_BRANCH}
                    git checkout ${GIT_DEFAULT_BRANCH}
                    status=$?
                    rm -rf ./.git/
                else
                    git archive --format=tar --remote=${GIT_REMOTEHOST_SSH} ${GIT_DEFAULT_BRANCH} | tar -xf -
                    status=$?
                fi
            else
                # github swtich
                if test $GIT_GITHUB_SWITCH == 1
                then
                    git clone --progress ${GIT_REMOTEHOST_SSH} ${GIT_DEFAULT_BRANCH}
                    git checkout $GITTAG
                    status=$?
                    rm -rf ./.git/
                else
                    git archive --format=tar --remote=${GIT_REMOTEHOST_SSH} $GITTAG | tar -xf -
                    status=$?
                fi
        fi
        # check git checkout
        if test $status -eq 2
        then
            echo "Git Checkout fehlgeschlagen!"
            exit
        fi

        cd ..
        ############################# change user and group #################################
        #chown -R ${G_WEBSERVER_USER}:${G_WEBSERVER_GROUP} $TAG/*

        # github swtich
        if test $GIT_GITHUB_SWITCH == 1
        then
            cd $TAG/${GIT_DEFAULT_BRANCH}
        else
            cd $TAG/
        fi

        ############################# replace version in config ##########################

        if test $FEATURE_VERSION_REPLACE == 1
        then
            sed -i -r "s/$VERSION_PATTERN\b/$TAG/g" "$PATH_VERSION_FILE"
            echo "Replace Version finished"
        fi

        ############################# go to build folder #################################
        if [ -d ${PATH_BUILD} ]
            then
                cd ${PATH_BUILD}
            else
                echo "Error: Finde build Ordner nicht..."
                exit
        fi

        ############################# composer #################################
        echo "Schritt 1: Prüfe composer.phar ..."
        # checken ob composer bereits da ist
        if [ -f ${COMPOSER_DEFAULT_NAME} ]
          then
            echo "Schritt 1: Die Datei composer.phar existiert bereits. [Done]"
            php ${COMPOSER_DEFAULT_NAME} self-update
            echo "Schritt 2: composer self update [Done]"
          else
            echo "Schritt 1: Die Datei composer.phar existiert nicht und muss heruntergeladen werden."
            curl -s ${COMPOSER_DONWLOAD_URL} | php
            if [ -f ${COMPOSER_DEFAULT_NAME} ]
                then
                    echo "Schritt 1: Download erfoglreich [Done]"
                else
                    echo "Schritt 1: Konnte nicht heruntergeladen werden [Error]"
                    exit
            fi
        fi

        echo "Schritt 3: Starte composer install"
        php ${COMPOSER_DEFAULT_NAME} --no-dev install
        echo "Schritt 4: Starte phing install"
        ${PATH_PHING} install

        ############################# permissions #################################
        # github swtich
        if test $GIT_GITHUB_SWITCH == 1
        then
            cd ../../../
        else
            cd ../../
        fi

        echo "Glückwusch die Installation ist beendet!"

        #############################################################################################
        ############################# Start Deploy to Remote Server #################################
        #############################################################################################

        echo "Start deploy auf Remote Server."

        # copy to server
        # github swtich
        if test $GIT_GITHUB_SWITCH == 1
        then
            if test $G_SYNC_MODE = "rsync"
            then
                rsync -r --progress $TAG/$GIT_DEFAULT_BRANCH/ $SERVER_USER@$SERVER_IP:$SERVER_PATH_TAGS/$TAG/
            else
                scp -r $TAG/$GIT_DEFAULT_BRANCH/ $SERVER_USER@$SERVER_IP:$SERVER_PATH_TAGS/$TAG/
            fi
        else
            if test $G_SYNC_MODE = "rsync"
            then
                rsync -r -v --progress $TAG/ $SERVER_USER@$SERVER_IP:$SERVER_PATH_TAGS/$TAG/
            else
                scp -r $TAG/ $SERVER_USER@$SERVER_IP:$SERVER_PATH_TAGS/$TAG/
            fi
        fi

        # using "" instead of '' to interpret the variables - change permissions | delete symlink | create symlink
        echo "Setzte Schreibrechte && Lösche alten Symlink && Erstelle Symlink"
        ssh $SERVER_USER@$SERVER_IP "chown -R ${SERVER_WEBSERVER_USER}:${SERVER_WEBSERVER_GROUP} ${SERVER_PATH_TAGS}/$TAG && rm ${SERVER_PATH_ACTIVE} && ln -s ${SERVER_PATH_TAGS}/$TAG/${SERVER_FOLDER_WWW} ${SERVER_PATH_ACTIVE}"

        # set permissions
        if test $CUSTOM_CHMOD == 1
        then
            for var in "${PATH_CHMOD_ARRAY[@]}"
            do
                ssh $SERVER_USER@$SERVER_IP "chmod $PATH_CHMOD_VALUE -R ${SERVER_PATH_TAGS}/$TAG/$var"
                echo "Setze Schreibrechte für ${SERVER_PATH_TAGS}/$TAG/$var"
            done
        fi

        # symlink project log folder to log folder
        if test $LOG_SYMLINKING == 1
        then
            ssh $SERVER_USER@$SERVER_IP "rm ${SERVER_PATH_LOG} && ln -s ${SERVER_PATH_TAGS}/$TAG/${SERVER_FOLDER_LOG} ${SERVER_PATH_LOG} && chown -R ${SERVER_WEBSERVER_USER}:${SERVER_WEBSERVER_GROUP} ${SERVER_PATH_LOG}"
        fi

        # clear cache folders
        if test $CLEAR_CACHE == 1
        then
            for var in "${PATH_CLEAR_CACHE_ARRAY[@]}"
            do
                ssh $SERVER_USER@$SERVER_IP "rm -rf ${SERVER_PATH_TAGS}/$TAG/$var"
                echo "Leere Cache Ordner: ${SERVER_PATH_TAGS}/$TAG/$var"
            done
        fi

        echo "Deploy Fertig!"

    else

        echo "Prozess beendet."

fi