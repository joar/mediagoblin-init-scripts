#!/bin/sh
## DESCRIPTION
# This script will download the mediagoblin init scripts and install them for
# you.
# The script needs to know where your mediagoblin installation is. By default
# this will be sed to what `pwd` will output when you run this script.
#
# This script uses the Dependency Based Boot in Debian >= 6.0
# <http://wiki.debian.org/LSBInitScripts/DependencyBasedBoot>
#
## USAGE
#
# # This will download the latest version of the installer.sh script directly
# # From gist.github.com (-L allowing a 302 redirect to raw.github.com), then
# # pipe the script directly through `sh` (presumably /bin/sh).
# $ curl -L http://wandborg.se/mediagoblin-init-scripts/installer.sh | sh
#
# By default the MG_ROOT will be set to `pwd` and the user will be set to the
# user you run the script as.
#
## LICENSE: CC0 <http://creativecommons.org/publicdomain/zero/1.0/>
# To the extent possible under law, Joar Wandborg <http://wandborg.se> has
# waived all copyright and related or neighboring rights to
# mediagoblin-paster. This work is published from Sweden.

if ! [ -z "$1" ]; then
    MEDIAGOBLIN_ROOT=$1
else
    MEDIAGOBLIN_ROOT=$(pwd)
fi

if ! [ -z "$2" ]; then
    MEDIAGOBLIN_USER=$2
else
    MEDIAGOBLIN_USER=$(whoami)
fi

PASTER_INIT_URL="http://wandborg.se/mediagoblin-init-scripts/mediagoblin-paster.sh"

PASTER_INIT_DESTINATION=/etc/init.d/mediagoblin-paster

CELERYD_INIT_URL="http://wandborg.se/mediagoblin-init-scripts/mediagoblin-celery-worker.sh"
CELERYD_INIT_DESTINATION=/etc/init.d/mediagoblin-celery-worker

verify_and_install () {
    INIT_PATH=$1
    # Check if installation of the init script was successful
    if [ -f "$INIT_PATH" ]; then
        # Set executable permissions on the init script
        sudo chmod +x $INIT_PATH
        echo "Installing the $INIT_PATH script"
        # More on `insserv` at <http://wiki.debian.org/LSBInitScripts/DependencyBasedBoot>
        sudo insserv $INIT_PATH
        return 0
    fi
    return 1
}

# Download the mediagoblin-paster script from raw.github.com, replace the
# MG_ROOT variable value with the $MEDIAGOBLIN_ROOT value and the MG_USER
# variable value with the $MEDIAGOBLIN_USER value and pipe it to
# the init script destination ($PASTER_INIT_DESTINATION).
sudo su -c "curl $PASTER_INIT_URL \
    | sed s,^MG_ROOT=.*\n,MG_ROOT=$MEDIAGOBLIN_ROOT, \
    | sed s,^MG_USER=.*\n,MG_USER=$MEDIAGOBLIN_USER, \
    > $PASTER_INIT_DESTINATION"

verify_and_install $PASTER_INIT_DESTINATION

# Download and fix the mediagoblin-celery-worker script
sudo su -c "curl $CELERYD_INIT_URL \
    | sed s,^MG_ROOT=.*\n,MG_ROOT=$MEDIAGOBLIN_ROOT, \
    | sed s,^MG_USER=.*\n,MG_USER=$MEDIAGOBLIN_USER, \
    > $CELERYD_INIT_DESTINATION"

verify_and_install $CELERYD_INIT_DESTINATION
