#!/bin/sh
set -e
set -x
echo "This script will output any commands that are running as they are running"

PASTER_INIT_URL="https://raw.github.com/gist/79020220c13a4839ea8b/mediagoblin-paster.sh"

PASTER_INIT_DESTINATION=/etc/init.d/mediagoblin-paster

sudo su -c "curl $PASTER_INIT_URL > $PASTER_INIT_DESTINATION"

if [ -f "$PASTER_INIT_DESTINATION" ]; then
    sudo chmod +x $PASTER_INIT_DESTINATION
    echo "Installing the $PASTER_INIT_DESTINATION script"
    sudo insserv $PASTER_INIT_DESTINATION
fi