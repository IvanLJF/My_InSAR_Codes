#! /bin/sh

msg=0

if [ -e /dev/sda2 ]; then
  mount /dev/sda2 /mnt/software
  msg=1
  echo "    /dev/sda2 -> /mnt/software"
fi

if [ -e /dev/sdb1 ]; then
  mount /dev/sdb1 /mnt/data_tli/
  msg=1
  echo "    /dev/sdb1 -> /mnt/data_tli"
fi

if [ $msg = 0 ]; then
  echo "No device was mounted."
else
  echo "Devices were mounted successfully."
fi
