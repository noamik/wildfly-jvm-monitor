#!/bin/bash

FPID="pids"
HOST=$(hostname)
TIMESTAMP=0

JPPID=""
JHPID=""
JSPID1=""
JSPID2=""
FIRST=true
JHSTAT=()
JPSTAT=()
JSTAT1=()
JSTAT2=()
SENDING_DATA=""

function getPids {
  JPPID=$(<$FPID/process-controller.pid)
  JHPID=$(<$FPID/host-controller.pid)
  JSPID1=$(<$FPID/slave-100.pid)
  JSPID2=$(<$FPID/slave-200.pid)
}

function getJstat {
  if [ -n "$1" ]; then
    TIMESTAMP=$(date +%s)
    if [[ $platform == 'sunos' ]]; then
      /opt/local/java/openjdk7/bin/jstat -gc -t $1
    else
      sudo -H -u wildfly bash -c "/usr/local/bin/jstat -gc -t $1"
    fi
  fi
}

function emptyJstatArray {
  echo "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
}

function checkStats {
  if [[ ${#JHSTAT[@]} < '16' ]] ; then JHSTAT=($(emptyJstatArray)) ; fi
  if [[ ${#JPSTAT[@]} < '16' ]] ; then JPSTAT=($(emptyJstatArray)) ; fi
  if [[ ${#JSTAT1[@]} < '16' ]] ; then JSTAT1=($(emptyJstatArray)) ; fi
  if [[ ${#JSTAT2[@]} < '16' ]] ; then JSTAT2=($(emptyJstatArray)) ; fi
}

function getHostData {
  SENDING_DATA="\"$HOST\" jvm.hostcontroller.S0C $TIMESTAMP ${JHSTAT[1]}
\"$HOST\" jvm.hostcontroller.S1C $TIMESTAMP ${JHSTAT[2]}
\"$HOST\" jvm.hostcontroller.S0U $TIMESTAMP ${JHSTAT[3]}
\"$HOST\" jvm.hostcontroller.S1U $TIMESTAMP ${JHSTAT[4]}
\"$HOST\" jvm.hostcontroller.EC $TIMESTAMP ${JHSTAT[5]}
\"$HOST\" jvm.hostcontroller.EU $TIMESTAMP ${JHSTAT[6]}
\"$HOST\" jvm.hostcontroller.OC $TIMESTAMP ${JHSTAT[7]}
\"$HOST\" jvm.hostcontroller.OU $TIMESTAMP ${JHSTAT[8]}
\"$HOST\" jvm.hostcontroller.PC $TIMESTAMP ${JHSTAT[9]}
\"$HOST\" jvm.hostcontroller.PU $TIMESTAMP ${JHSTAT[10]}
\"$HOST\" jvm.hostcontroller.YGC $TIMESTAMP ${JHSTAT[11]}
\"$HOST\" jvm.hostcontroller.YGCT $TIMESTAMP ${JHSTAT[12]}
\"$HOST\" jvm.hostcontroller.FGC $TIMESTAMP ${JHSTAT[13]}
\"$HOST\" jvm.hostcontroller.FGCT $TIMESTAMP ${JHSTAT[14]}
\"$HOST\" jvm.hostcontroller.GCT $TIMESTAMP ${JHSTAT[15]}"
}

function getProcessData {
  SENDING_DATA="\"$HOST\" jvm.processcontroller.S0C $TIMESTAMP ${JPSTAT[1]}
\"$HOST\" jvm.processcontroller.S1C $TIMESTAMP ${JPSTAT[2]}
\"$HOST\" jvm.processcontroller.S0U $TIMESTAMP ${JPSTAT[3]}
\"$HOST\" jvm.processcontroller.S1U $TIMESTAMP ${JPSTAT[4]}
\"$HOST\" jvm.processcontroller.EC $TIMESTAMP ${JPSTAT[5]}
\"$HOST\" jvm.processcontroller.EU $TIMESTAMP ${JPSTAT[6]}
\"$HOST\" jvm.processcontroller.OC $TIMESTAMP ${JPSTAT[7]}
\"$HOST\" jvm.processcontroller.OU $TIMESTAMP ${JPSTAT[8]}
\"$HOST\" jvm.processcontroller.PC $TIMESTAMP ${JPSTAT[9]}
\"$HOST\" jvm.processcontroller.PU $TIMESTAMP ${JPSTAT[10]}
\"$HOST\" jvm.processcontroller.YGC $TIMESTAMP ${JPSTAT[11]}
\"$HOST\" jvm.processcontroller.YGCT $TIMESTAMP ${JPSTAT[12]}
\"$HOST\" jvm.processcontroller.FGC $TIMESTAMP ${JPSTAT[13]}
\"$HOST\" jvm.processcontroller.FGCT $TIMESTAMP ${JPSTAT[14]}
\"$HOST\" jvm.processcontroller.GCT $TIMESTAMP ${JPSTAT[15]}"
}

function getSlave100Data {
  SENDING_DATA="\"$HOST\" jvm.slave100.S0C $TIMESTAMP ${JSTAT1[1]}
\"$HOST\" jvm.slave100.S1C $TIMESTAMP ${JSTAT1[2]}
\"$HOST\" jvm.slave100.S0U $TIMESTAMP ${JSTAT1[3]}
\"$HOST\" jvm.slave100.S1U $TIMESTAMP ${JSTAT1[4]}
\"$HOST\" jvm.slave100.EC $TIMESTAMP ${JSTAT1[5]}
\"$HOST\" jvm.slave100.EU $TIMESTAMP ${JSTAT1[6]}
\"$HOST\" jvm.slave100.OC $TIMESTAMP ${JSTAT1[7]}
\"$HOST\" jvm.slave100.OU $TIMESTAMP ${JSTAT1[8]}
\"$HOST\" jvm.slave100.PC $TIMESTAMP ${JSTAT1[9]}
\"$HOST\" jvm.slave100.PU $TIMESTAMP ${JSTAT1[10]}
\"$HOST\" jvm.slave100.YGC $TIMESTAMP ${JSTAT1[11]}
\"$HOST\" jvm.slave100.YGCT $TIMESTAMP ${JSTAT1[12]}
\"$HOST\" jvm.slave100.FGC $TIMESTAMP ${JSTAT1[13]}
\"$HOST\" jvm.slave100.FGCT $TIMESTAMP ${JSTAT1[14]}
\"$HOST\" jvm.slave100.GCT $TIMESTAMP ${JSTAT1[15]}"
}

function getSlave200Data {
  SENDING_DATA="\"$HOST\" jvm.slave200.S0C $TIMESTAMP ${JSTAT2[1]}
\"$HOST\" jvm.slave200.S1C $TIMESTAMP ${JSTAT2[2]}
\"$HOST\" jvm.slave200.S0U $TIMESTAMP ${JSTAT2[3]}
\"$HOST\" jvm.slave200.S1U $TIMESTAMP ${JSTAT2[4]}
\"$HOST\" jvm.slave200.EC $TIMESTAMP ${JSTAT2[5]}
\"$HOST\" jvm.slave200.EU $TIMESTAMP ${JSTAT2[6]}
\"$HOST\" jvm.slave200.OC $TIMESTAMP ${JSTAT2[7]}
\"$HOST\" jvm.slave200.OU $TIMESTAMP ${JSTAT2[8]}
\"$HOST\" jvm.slave200.PC $TIMESTAMP ${JSTAT2[9]}
\"$HOST\" jvm.slave200.PU $TIMESTAMP ${JSTAT2[10]}
\"$HOST\" jvm.slave200.YGC $TIMESTAMP ${JSTAT2[11]}
\"$HOST\" jvm.slave200.YGCT $TIMESTAMP ${JSTAT2[12]}
\"$HOST\" jvm.slave200.FGC $TIMESTAMP ${JSTAT2[13]}
\"$HOST\" jvm.slave200.FGCT $TIMESTAMP ${JSTAT2[14]}
\"$HOST\" jvm.slave200.GCT $TIMESTAMP ${JSTAT2[15]}"
}

function sendStats {
  # zabbix_sender $ZS_PARAM -z service.theluckycatcasino.com -s "$(hostname)" -k "cluster.status" -o "$CLUSTER_STATUS" >> $TEMP_LOG_FILE
  getProcessData
  echo "$SENDING_DATA"
#  result=$(echo "$SENDING_DATA" | zabbix_sender -c $ZABBIX_AGENTD_CONF -v -T -i - 2>&1)
  getHostData
  echo "$SENDING_DATA"
#  result=$(echo "$SENDING_DATA" | zabbix_sender -c $ZABBIX_AGENTD_CONF -v -T -i - 2>&1)
  getSlave100Data
  echo "$SENDING_DATA"
#  result=$(echo "$SENDING_DATA" | zabbix_sender -c $ZABBIX_AGENTD_CONF -v -T -i - 2>&1)
  getSlave200Data
  echo "$SENDING_DATA"
#  result=$(echo "$SENDING_DATA" | zabbix_sender -c $ZABBIX_AGENTD_CONF -v -T -i - 2>&1)
}


function getStats {
  #sudo -H -u wildfly bash -c '/usr/local/bin/jstat -gc -t 20674' && sudo -H -u wildfly bash -c '/usr/local/bin/jstat -gcutil -t 20674' && sudo -H -u wildfly bash -c "/usr/local/bin/jmap -heap 20674"
  # Timestamp        S0C    S1C    S0U    S1U      EC       EU        OC         OU       PC     PU    YGC     YGCT    FGC    FGCT     GCT
  #       107737.6 8704.0 8704.0 2751.9  0.0   70208.0  32418.3   174784.0   29565.4   36288.0 36022.9      6    0.186   2      0.222    0.408
  JHSTAT=($(getJstat $JHPID | grep -v "Timestamp"))
  JPSTAT=($(getJstat $JPPID | grep -v "Timestamp"))
  if [[ -n "JSPID1" ]] ; then
    JSSTAT1=($(getJstat $JSPID1 | grep -v "Timestamp"))
    JSSTAT2=($(getJstat $JSPID2 | grep -v "Timestamp"))
  fi
  checkStats
  sendStats
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
. ./get-platform.sh
getPids
checkRunning
