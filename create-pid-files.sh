#!/bin/bash

TEMP="/tmp"
PIDF="pids"



TEMP_OUT=$TMP/test-jps-output.txt
PRO_STR="Process Controller"
HOS_STR="Host Controller"
SLA_STR="Slave"


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
sudo -H -u wildfly bash -c "/usr/local/bin/jps -v" > $TEMP_OUT
JPIDS=($(<$TEMP_OUT))
rm -f $TEMP_OUT
IFS=$SAFEIFS 

for i in "${JPIDS[@]}"
do
  TMP=$(echo $i | grep "Process Controller" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JPPID=$TMP
  fi
  TMP=$(echo $i | grep "Host Controller" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JHPID=$TMP
  fi
  TMP=$(echo $i | grep "Slave" | grep "100" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JSPID1=$TMP
  fi
  TMP=$(echo $i | grep "Slave" | grep "200" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JSPID2=$TMP
  fi
done

if [ -n "$JPPID" ]
then
  echo $JPPID > $PIDF/process-controller.pid
fi
if [ -n "$JHPID" ]
then
  echo $JHPID > $PIDF/host-controller.pid
fi
if [ -n "$JSPID1" ]
then
  echo $JSPID1 > $PIDF/slave-100.pid
fi
if [ -n "$JSPID2" ]
then
  echo $JSPID2 > $PIDF/slave-200.pid
fi
