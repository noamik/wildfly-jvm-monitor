#!/bin/bash

FPID="pids"

JPPID=""
JHPID=""
JSPID1=""
JSPID2=""
FIRST=true

function getPids {
  JPPID=$(<$FPID/process-controller.pid)
  JHPID=$(<$FPID/host-controller.pid)
  JSPID1=$(<$FPID/slave-100.pid)
  JSPID2=$(<$FPID/slave-200.pid)
}

function getStats {
  #sudo -H -u wildfly bash -c '/usr/local/bin/jstat -gc -t 20674' && sudo -H -u wildfly bash -c '/usr/local/bin/jstat -gcutil -t 20674' && sudo -H -u wildfly bash -c "/usr/local/bin/jmap -heap 20674"
  echo "Cool"
}

function checkRunning {
if [[ -n "$JHPID" ]] ; then
  if ps -p $JHPID  > /dev/null 2>&1
  then 
    getStats
  else
   if [ "$FIRST" = true ]
   then
      FIRST=false
      ./create-pid-files.sh
      getPids
      checkRunning
    else
      exit 1
    fi
  fi
fi
}

getPids
checkRunning
