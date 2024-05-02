# Usage of udisk

[eject usb disk](https://unix.stackexchange.com/questions/35508/eject-usb-drives-eject-command)

power off the udisk(for example /dev/sdc)

    udisksctl power-off -b /dev/sdc

~~Manual steps for unmounting disk /dev/sdc (Requires sudo)~~

    echo 'offline' > /sys/block/sdc/device/state
    echo '1' > /sys/block/sdc/device/delete
