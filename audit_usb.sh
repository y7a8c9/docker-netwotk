#!/bin/bash

# Logging function
log_to_file() {
    local file_path="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local username=$(whoami)
    local sha512_hash=$(sha512sum "$file_path" | awk '{print $1}')
    local md5_hash=$(md5sum "$file_path" | awk '{print $1}')
    local file_name=$(basename "$file_path")

    echo "$timestamp <$username> $file_name SHA512: $sha512_hash, MD5: $md5_hash" >> /opt/data/usb.log
}

# Function to find the mount point of a USB device
find_mount_point() {
    for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        
        if [[ "$devname" == "bus/"* ]]; then
            continue
        fi

        eval "$(udevadm info -q property --export -p $syspath)"

        if [[ -z "$ID_FS_UUID" ]]; then
            continue
        fi

        mountpoint=$(findmnt -rn -S "/dev/$devname" -o TARGET)
        if [[ -n "$mountpoint" ]]; then
            echo "$mountpoint"
            break
        fi
    done
}

# Function to handle new files
on_new_file() {
    log_to_file "$1"
}

# Find the mount point of the newly connected USB device
USB_MOUNT_POINT=$(find_mount_point)

if [[ -n "$USB_MOUNT_POINT" ]]; then
    # Monitor for new files using inotifywait
    inotifywait -m -e create --format '%w%f' "$USB_MOUNT_POINT" | while read FILE
    do
        if [[ -f "$FILE" ]]; then
            on_new_file "$FILE"
        fi
    done
else
    echo "No USB mount point found."
fi
