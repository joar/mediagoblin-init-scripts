#!/bin/sh
# /etc/init.d/mediagoblin-paster
#
## LICENSE: CC0 <http://creativecommons.org/publicdomain/zero/1.0/>
# To the extent possible under law, Joar Wandborg <http://wandborg.se> has
# waived all copyright and related or neighboring rights to
# mediagoblin-paster. This work is published from Sweden.
#
## CREDIT
# Credit goes to jpope <http://jpope.org/> and 
# chimo <http://chimo.chromic.org/>. From which' Arch init scripts this is
# based upon.
#
# ### BEGIN INIT INFO
# Provides:          mediagoblin-paster
# Required-Start:    $network $named $local_fs
# Required-Stop:     $remote_fs $syslog $network $named $local_fs
# Should-Start:      nginx $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: MediaGoblin paster init script
# Description:       This script will initiate the GNU MediaGoblin paster
#                    fcgi server.
### END INIT INFO

################################################################################
# CHANGE THIS
# to suit your environment
################################################################################
MG_ROOT=/home/joar/git/mediagoblin
################################################################################
# NOW STOP
# You probably won't have to change anything else.
################################################################################

set -e

DAEMON_NAME=mediagoblin-paster

MG_BIN=$MG_ROOT/bin
MG_PASTER_BIN=$MG_BIN/paster
MG_PASTE_INI=$MG_ROOT/paste_local.ini
MG_USER=joar
MG_FCGI_HOST=127.0.0.1
MG_FCGI_PORT=26543
MG_PASTER_PID_FILE=/var/run/mediagoblin/$DAEMON_NAME.pid
MG_PASTER_LOG_FILE=/var/log/mediagoblin/$DAEMON_NAME.log

set_up_directories() {
    install -o $MG_USER -g users -d -m 755 /var/log/mediagoblin
    install -o $MG_USER -g users -d -m 755 /var/run/mediagoblin
}

set_up_directories

getPID() {
    # Discard any errors from cat
    cat $MG_PASTER_PID_FILE 2>/dev/null
}

case "$1" in 
    start)
        # Start the MediaGoblin paster process
        echo "Starting $DAEMON_NAME..."
        if [ -z "$(getPID)" ]; then
            su -s /bin/sh -c "CELERY_ALWAYS_EAGER=false ${MG_PASTER_BIN} serve \
                $MG_PASTE_INI \
                --server-name=fcgi \
                fcgi_host=$MG_FCGI_HOST fcgi_port=$MG_FCGI_PORT \
                --pid-file=$MG_PASTER_PID_FILE \
                --log-file=$MG_PASTER_LOG_FILE \
                --daemon" - $MG_USER &>/dev/null &

            # Sleep for a while until we're kind of certain that paster has
            # had it's time to initialize
            sleep 5

            if [ $? -gt 0 ] || [ -z "$(getPID)" ]; then
                echo "Couldn't start paster process. See $MG_PASTER_LOG_FILE" 
                echo "for details."
            else
                echo "MediaGoblin paster process started with PID $(getPID)."
            fi
        else
            echo "$DAEMON_NAME server already running based on"
            echo "$MG_PASTER_PID_FILE."
        fi
        ;;
    stop)
        # Kill the MediaGoblin paster process
        echo "Stopping $DAEMON_NAME..."
        if [ -z "$(getPID)" ]; then
            echo "Doesn't seem like $DAEMON_NAME is running based on"
            echo "$MG_PASTER_PID_FILE"
        else
            kill $(getPID)

            # Give some time to paster trying to stop
            sleep 5

            if [ $? -gt 0 ]; then
                echo "Couldn't stop $DAEMON_NAME, make sure it's still running"
                echo "then remove $MG_PASTER_PID_FILE if needed."
            else
                echo "$DAEMON_NAME stopped."
            fi
        fi
        ;;
    restart)
        $0 stop
        sleep 5
        $0 start
        ;;
    status)
        if ! [ -z "$(getPID)" ]; then
            echo "$DAEMON_NAME start/running, process $(getPID)"
        else
            echo "$DAEMON_NAME stopped."
        fi
        ;;
    *)
        echo "Usage: $0 {restart|start|stop}"
        exit 1
        ;;
esac

exit 0