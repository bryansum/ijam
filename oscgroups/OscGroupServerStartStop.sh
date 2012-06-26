#! /bin/sh
#
# This is a start/stop script to be used with the Linux init.d mechanism
# so that the OSCgroups server is restarted when Linux is restarted.
# To use this script, first edit the lines below so that OSCGROUPSERVER 
# is the path to the OscGroupServer binary and LOGFILE is the path to 
# a file where the server will write log messages. The PORT, MAXUSERS,
# MAXGROUPS and TIMEOUTSECONDS variables map to the corresponding  
# OscGroupServer parameters. You can also edit the USER variable to  
# execute the server as a different Unix user.
#
# to install this script place it in /etc/init.d (or link it using ln -s)
#
# then add it to the global startup/shutdown scripts using:
#
# $ update-rc.d OscGroupServerStartStop.sh defaults
#
# you can also run it manually using:
# 
# $ OscGroupServerStartStop.sh start
#
# for more info see:
# man start-stop-daemon
# man update-rc.d
# cat /etc/init.d/skeleton
#

OSCGROUPSERVER=/root/oscgroups/OSCgroups/bin/OscGroupServer
LOGFILE=/root/logs/oscgroupserver.log
PORT=22242
TIMEOUTSECONDS=60
MAXUSERS=500
MAXGROUPS=500

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=$OSCGROUPSERVER
NAME="OscGroupServer"
DESC="OscGroupServer: OSCgroups NAT traversal daemon"
OPTIONS="-l $LOGFILE";
USER=root
PIDFILE=/var/run/$NAME.pid
STOPSIGNAL=INT

test -x $DAEMON || echo Error: $DAEMON missing or not executable
test -x $DEAMON || exit 0

set -e


d_start() {
        start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE \
                --chuid $USER --exec $DAEMON -- $OPTIONS
}

d_stop() {
        start-stop-daemon --stop --pidfile $PIDFILE \
                --signal $STOPSIGNAL
}

case "$1" in
  start)
        echo -n "Starting $DESC: $NAME"
        d_start
        echo "."
        ;;
  stop)
        echo -n "Stopping $DESC: $NAME"
        d_stop
        echo "."
        ;;
 
  restart|force-reload)
        echo -n "Restarting $DESC: $NAME"
        d_stop
        sleep 1
        d_start
        echo "."
        ;;
  *)
        echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac

exit 0

