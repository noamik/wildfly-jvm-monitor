#!/bin/bash

# Configurables
TEMP="/tmp"
PIDF="pids"

# Non-Configurables
TEMP_OUT=$TMP/test-jps-output.txt

# Querying plattform
platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='freebsd'
elif [[ "$unamestr" == 'SunOS' ]]; then
   platform='sunos'
fi

# Getting running jvms
if [[ $platform == 'sunos' ]]; then
  /opt/local/java/openjdk7/bin/jps -v > $TEMP_OUT
else
  sudo -H -u wildfly bash -c "/usr/local/bin/jps -v" > $TEMP_OUT
fi

# Parsing process strings into array
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
#/opt/local/java/openjdk7/bin/jstat -gc -t $i
JPIDS=($(<$TEMP_OUT))
rm -f $TEMP_OUT
IFS=$SAFEIFS 

# Storing respective jvm process ids in the respective variable
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

# Storing variables to files
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
