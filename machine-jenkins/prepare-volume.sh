#!/usr/bin/env bash
set -e

if [ -z "$1" ];
  then
    echo "Error: 1. parameter is missing"
    exit 1;
  else
    VOLUME_ID=$1;
    VOLUME_SN=$(echo "$VOLUME_ID" | tr -d -)
  fi

if [ -z "$2" ];
  then
    echo "Error: 2. parameter is missing"
    exit 1;
  else
    VOLUME_LABEL=$2;
  fi

if [ -z "$3" ];
  then
    echo "Error: 3. parameter is missing"
    exit 1;
  else
    MOUNT_POINT=$3;
  fi

echo "VOLUME_ID=$VOLUME_ID"
echo "VOLUME_SN=$VOLUME_SN"
echo "VOLUME_LABEL=$VOLUME_LABEL"
echo "MOUNT_POINT=$MOUNT_POINT"

echo "CHECK: validate volDevPath with SN?"
if [ $(nvme list | grep $VOLUME_SN | wc -l) -eq 1  ];
  then
    DEV_PATH=$(nvme list | grep $VOLUME_SN | awk ' {print $1; exit}')
    echo "OK: DEV_PATH=$DEV_PATH"
  else
    echo "ERR: CAN NOT FIND VOLUME WITH SN=$VOLUME_SN"
    exhit 1
  fi

echo "CHECK: EXIST Volume with Label?"
if [ $(lsblk -o LABEL | grep $VOLUME_LABEL) = $VOLUME_LABEL ];
  then
    echo "OK: LABEL Exist No Formated Required"
  else
    echo "NO: FORMATING AND LABELING VOLUME"
    mkfs -t ext4 $DEV_PATH
    e2label $DEV_PATH $VOLUME_LABEL
  fi

echo "CHECK: LABEL ENTRY EXISTING IN FSTAB?"
if [ $(cat /etc/fstab | grep $VOLUME_LABEL | wc -l) -eq 1 ];
  then
    echo "OK: LABEL ENTRY EXISTING, NOT NEED CREATE"
  else
    echo "NO: CREATE FSTAB LINE"
      mkdir -p $MOUNT_POINT
      echo "LABEL=$VOLUME_LABEL   $MOUNT_POINT   ext4  defaults,discard   0 0" | tee -a /etc/fstab
  fi

echo "CHECK: MOUNT POINT MOUNTED?"
if [ $(df -aTh | grep $MOUNT_POINT | wc -l) -eq 1 ];
  then
    echo "OK: MOUNTED ALREADY"
  else
    echo "NO: MOUNTING REQUIRED"
    mount $MOUNT_POINT
  fi

#TODO resize2fs

