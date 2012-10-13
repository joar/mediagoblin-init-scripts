#!/bin/bash
# /etc/init.d/mediagoblin-celeryd
#
## LICENSE: CC0 <http://creativecommons.org/publicdomain/zero/1.0/>
# To the extent possible under law, Joar Wandborg <http://wandborg.se> has
# waived all copyright and related or neighboring rights to
# mediagoblin-celeryd. This work is published from Sweden.
#
## CREDIT
# Credit goes to jpope <http://jpope.org/> and 
# chimo <http://chimo.chromic.org/>. From which' Arch init scripts this is
# based upon.
#
### BEGIN INIT INFO
# Provides:          mediagoblin-celeryd
# Required-Start:    $network $named $local_fs
# Required-Stop:     $remote_fs $syslog $network $named $local_fs
# Should-Start:      postgres $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: MediaGoblin Celery task processor init script
# Description:       This script will initiate the GNU MediaGoblin Celery 
#                    task processor 
### END INIT INFO

################################################################################
# CHANGE THIS
# to suit your environment
################################################################################
MG_ROOT=/home/joar/git/mediagoblin
MG_USER=joar
################################################################################
# NOW STOP
# You probably won't have to change anything else.
################################################################################

set -e

DAEMON_NAME=mediagoblin-celeryd

MG_BIN=$MG_ROOT/bin
MG_CELERYD_BIN=$MG_BIN/celeryd
MG_CONFIG=$MG_ROOT/mediagoblin_local.ini
MG_CELERY_CONFIG_MODULE=mediagoblin.init.celery.from_celery
MG_CELERYD_PID_FILE=/var/run/mediagoblin/$DAEMON_NAME.pid
MG_CELERYD_LOG_FILE=/var/log/mediagoblin/$DAEMON_NAME.log

set_up_directories() {
    install -o $MG_USER -g users -d -m 755 /var/log/mediagoblin
    install -o $MG_USER -g users -d -m 755 /var/run/mediagoblin
}

set_up_directories

# Include LSB helper functions
. /lib/lsb/init-functions

wait_for_death() {
    pid=$1
    seconds=1

    if [ -z "$2" ]; then
        kill_at=20
    else
        kill_at=$2
    fi

    if [ -z "$pid" ]; then
        log_action_msg "Could not get PID. Aborting"
        log_end_msg 1
        exit 1
    fi

    while ps ax | grep -v grep | grep $pid > /dev/null; do
        sleep 1
        seconds=$(expr $seconds + 1)
        if [ $seconds -ge $kill_at ]; then
            log_action_msg "Failed to shut down after $kill_at seconds. Aborting"
            log_end_msg 1
            exit 1
        fi
    done
    log_end_msg 0
}

wait_for_pidfile() {
    pidfile=$1
    kill_at=20
    seconds=1

    while ! [[ -f $pidfile ]]; do
        sleep 1
        seconds=$(expr $seconds + 1)

        if [ $seconds -ge $kill_at ]; then
            log_action_msg "Can't find the PID file," \
                " the application must have crashed."
            log_end_msg 1
            exit 1
        fi
    done
}

getPID() {
    # Discard any errors from cat
    cat $MG_CELERYD_PID_FILE 2>/dev/null
}

case "$1" in 
    start)
        # Start the MediaGoblin celeryd process
        log_daemon_msg "Starting GNU MediaGoblin Celery task queue" "$DAEMON_NAME"
        if [ -z "$(getPID)" ]; then
            # TODO: Could we send things to log a little bit more beautiful?
            su -s /bin/sh -c "cd $MG_ROOT && \
                MEDIAGOBLIN_CONFIG=$MG_CONFIG \
                CELERY_CONFIG_MODULE=$MG_CELERY_CONFIG_MODULE \
                $MG_CELERYD_BIN \
                --pidfile=$MG_CELERYD_PID_FILE \
                -f $MG_CELERYD_LOG_FILE 2>&1 >> $MG_CELERYD_PID_FILE" \
                - $MG_USER 2>&1 >> $MG_CELERYD_LOG_FILE &

            CELERYD_RESULT=$?

            wait_for_pidfile $MG_CELERYD_PID_FILE

            log_end_msg $CELERYD_RESULT
        else
            # Failed because the PID file indicates it's running
            log_action_msg "PID file $MG_CELERYD_PID_FILE already exists"
            log_end_msg 1
        fi
        ;;
    stop)
        log_daemon_msg "Stopping GNU MediaGoblin Celery task queue" "$DAEMON_NAME"
        if [ -z "$(getPID)" ]; then
            # Failed because the PID file indicates it's not running
            log_action_msg "Could not get PID"
            log_end_msg 1
            exit 1
        else
            kill $(getPID)

            wait_for_death $(getPID)
        fi
        ;;
    restart)
        $0 stop
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
        echo "Usage: $0 {restart|start|stop|status}"
        exit 1
        ;;
esac

exit 0
