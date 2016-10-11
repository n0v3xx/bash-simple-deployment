#!/usr/bin/env bash

# include config
source config.sh

# Installation
echo "Willkommen zum deployment deines Projektes"
read -p "Installation auf lokales Gerät oder Deploy Server? (local | live): " env

if [ "$env" = ${G_DEFAULT_ENV} ]
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
        read -p "Erstelle Tag Ordner (z.B. 1.0.0): " tag
        mkdir $tag
        cd $tag

        ############################# checkout from git #################################
        read -p "Checkout Tag (z.B. 1.0.0) (default: master): " gittag
        if [ "$gittag" != ${GIT_DEFAULT_BRANCH} ]
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
                    git checkout $gittag
                    status=$?
                    rm -rf ./.git/
                else
                    git archive --format=tar --remote=${GIT_REMOTEHOST_SSH} $gittag | tar -xf -
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
        chown -R ${G_WEBSERVER_USER}:${G_WEBSERVER_GROUP} $tag/*

        # github swtich
        if test $GIT_GITHUB_SWITCH == 1
        then
            cd $tag/${GIT_DEFAULT_BRANCH}
        else
            cd $tag/
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

        chown -R ${G_WEBSERVER_USER}:${G_WEBSERVER_GROUP} $tag/*
        # Schleife für alle Ordner
        for var in "${PATH_CHMOD_ARRAY[@]}"
        do
            if test $GIT_GITHUB_SWITCH == 1
            then
                chmod 777 -R $tag/$GIT_DEFAULT_BRANCH/$var/*
            else
                chmod 777 -R $tag/$var/*
            fi
        done

        echo "Glückwusch die Installation ist beendet!"

        #############################################################################################
        ############################# Start Deploy to Remote Server #################################
        #############################################################################################

        echo "Start deploy auf Remote Server."

        # copy to server
        # github swtich
        if test $GIT_GITHUB_SWITCH == 1
        then
            scp -r $tag/$GIT_DEFAULT_BRANCH/ $SERVER_USER@$SERVER_IP:$SERVER_PATH_TAGS/$tag/
        else
            scp -r $tag/ $SERVER_USER@$SERVER_IP:$SERVER_PATH_TAGS/$tag/
        fi

        ## alternative @todo Test it with rsync
        #rsync -r -v --progress -e ssh user@remote-system:/address/to/remote/file /home/user/

        # using "" instead of '' to interpret the variables - change permissions | delete symlink | create symlink
        ssh $SERVER_USER@$SERVER_IP "chown -R ${SERVER_WEBSERVER_USER}:${SERVER_WEBSERVER_GROUP} ${SERVER_PATH_TAGS}/$tag | rm ${SERVER_PATH_ACTIVE} | ln -s ${SERVER_PATH_TAGS}/$tag/${SERVER_PATH_WWW} ${SERVER_PATH_ACTIVE}"

        echo "Deploy Fertig!"

    else
        # Projekt auschecken
#        git archive --format=tar --remote=${GIT_REMOTEHOST_SSH} ${GIT_DEFAULT_BRANCH} | tar -xf -
#
#        # aus dem Verzeichnis /script raus gehen und ins /build wechseln
#        cd ${PATH_BUILD}
#        echo "Schritt 1: Prüfe composer.phar ..."
#
#        # checken ob composer bereits da ist
#        if [ -f ${COMPOSER_DEFAULT_NAME} ]
#          then
#            echo "Schritt 1: Die Datei composer.phar existiert bereits. [Done]"
#            php ${COMPOSER_DEFAULT_NAME} self-update
#            echo "Schritt 2: composer self update [Done]"
#          else
#            echo "Schritt 1: Die Datei composer.phar existiert nicht und muss heruntergeladen werden."
#            curl -s ${COMPOSER_DONWLOAD_URL} | php
#            if [ -f ${COMPOSER_DEFAULT_NAME} ]
#                then
#                    echo "Schritt 1: Download erfoglreich [Done]"
#                else
#                    echo "Schritt 1: Konnte nicht heruntergeladen werden [Error]"
#            fi
#        fi
#
#        echo "Lokale Installation:"
#        echo "Schritt 3: Starte composer update"
#        php ${COMPOSER_DEFAULT_NAME} update
#        echo "Schritt 3: composer update [Done]"
#
#        echo "Schritt 4: Starte composer install"
#        php ${COMPOSER_DEFAULT_NAME} install
#        echo "Schritt 4: composer install [Done]"
#
#        echo "Schirtt 5: Phing install starten"
#        # phing install
#        ${PATH_PHING} install
#
#        # SCHREIBRECHTE!
#        cd ../
#
#        # Schleife für alle Ordner
#        for var in "${PATH_CHMOD_ARRAY[@]}"
#        do
#            chmod 777 -R $tag/var/*
#        done
#
        echo "Glückwusch die Installation ist beendet!"
fi