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
# $ curl -L https://gist.github.com/raw/79020220c13a4839ea8b/installer.sh | sh
#
## LICENSE: CC0 <http://creativecommons.org/publicdomain/zero/1.0/>
# To the extent possible under law, Joar Wandborg <http://wandborg.se> has
# waived all copyright and related or neighboring rights to
# mediagoblin-paster. This work is published from Sweden.

echo "* This script will output the commands as they are running from now on..."
set -x
set -e

if ! [ -z "$1" ]; then
    MEDIAGOBLIN_ROOT=$1
else
    MEDIAGOBLIN_ROOT=$(pwd)
fi

PASTER_INIT_URL="https://raw.github.com/gist/79020220c13a4839ea8b/mediagoblin-paster.sh"

PASTER_INIT_DESTINATION=/etc/init.d/mediagoblin-paster

# Download the mediagoblin-paster script from raw.github.com, replace the
# MG_ROOT variable value with the $MEDIAGOBLIN_ROOT value and pipe it to
# the init script destionation ($PASTER_INIT_DESTINATION).
sudo su -c "curl $PASTER_INIT_URL \
    | sed s,^MG_ROOT=.*\n,MG_ROOT=$MEDIAGOBLIN_ROOT, \
    > $PASTER_INIT_DESTINATION"

# Check if installation of the init script was successful
if [ -f "$PASTER_INIT_DESTINATION" ]; then
    # Set executable permissions on the init script
    sudo chmod +x $PASTER_INIT_DESTINATION
    echo "Installing the $PASTER_INIT_DESTINATION script"
    # More on `insserv` at <http://wiki.debian.org/LSBInitScripts/DependencyBasedBoot>
    sudo insserv $PASTER_INIT_DESTINATION
fi
