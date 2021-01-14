# /dev/sda1 1G	boot
# /dev/sda2 50G /
# /dev/sda3 4G swap
# /dev/sda4 -  home

# zap all old partition first
sgdisk --zap-all /dev/sda

fdisk /dev/sda << EOF
n



+1G
n



+50G
n



+4G
t
3
82
n
p


w
EOF

mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
mkfs.ext4 /dev/sda4
