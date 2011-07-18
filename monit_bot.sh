#!/usr/bin/env bash

if [ $# -lt 1 ] ; then
    echo "Usage:   " $0 " <start | stop> "
    exit 1
fi

action=$1

script_location=$(cd ${0%/*} && pwd -P)

logfile=$script_location/monit_job.log
echo "-----------------------------------------------" >> $logfile 2>&1
echo "Running bundle exec ./bot/bot_control.rb $action" >> $logfile 2>&1
echo `date` >> $logfile 2>&1
echo `env` >> $logfile 2>&1

/usr/local/bin/rvm reload >> $logfile 2>&1
`which bundle` exec $script_location/bot_control.rb $action >> $logfile 2>&1

