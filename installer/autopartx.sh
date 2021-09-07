DISK_NAME=$1

# sdx1 /boot
BOOT_SIZE="+1G"

# sdx2 /
ROOT_SIZE="+100G"

# sdx3 swap
SWAP_SIZE="+80G"

# sdx4 /home

[ ! $# -eq 1 ] && { echo "Usage $0 /dev/sdx"; exit; }

# zap all old partition first
sgdisk -V > /dev/null || { echo "sgdisk(gptfdisk) need to be installed"; exit; }
sgdisk --zap-all $DISK_NAME
wipefs --all -f $DISK_NAME

fdisk $DISK_NAME << EOF
n



$BOOT_SIZE
n



$ROOT_SIZE
n



$SWAP_SIZE
t
3
82
n
p


w
EOF

mkfs.fat -F 32 ${DISK_NAME}1
echo y | mkfs.ext4 ${DISK_NAME}2
mkswap ${DISK_NAME}3
echo y | mkfs.ext4 ${DISK_NAME}4
