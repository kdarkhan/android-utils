#!/bin/sh

set -e

echo "Starting script"

iso_file="${@}"

if [ -n "$iso_file" ]; then
    echo "Using \"${iso_file}\""
else
    for file in /sdcard/iso/*.iso; do
        if [ -f "$file" ]; then
            iso_file=$file
            echo "Using default ${iso_file} because nothing was provided"
            break
        fi
    done
fi

if [ ! -f "$iso_file" ]; then
    echo "Could not find iso file at [$iso_file]"
    exit 1
fi


# [sys.usb.config]: [mass_storage,adb]
props=$(getprop | grep "\[sys.usb.config\]" | sed -E 's/\[sys.usb.config\]: \[(.*)\]/\1/')

echo "sys.usb.config has [$props]"

if [ $(id -u) -ne 0 ]; then
  echo "This script must be run under root, aborting"
  exit 2
fi

if [[ "$props" == *mass_storage* ]]; then
  echo "Already contains mass_storage, skipping..."
else
  echo "Does not contain mass_storage, executing setprop"

  if [ -n "$props" ]; then
    echo "props is not empty, prepending mass_storage"
    setprop sys.usb.config "mass_storage,$props"
    setprop sys.usb.state "mass_storage,$props"
  else
    echo "props is empty, setting to just mass_storage"
    setprop sys.usb.config "mass_storage"
    setprop sys.usb.state "mass_storage"
  fi
fi

usb_dir="/config/usb_gadget/g1/functions/mass_storage.0/lun.0"

echo "Pushing contents now"

echo $iso_file > "$usb_dir/file"
echo `basename $iso_file` > "$usb_dir/inquiry_string"

echo "All done, connect the device now"
