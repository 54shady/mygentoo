# https://github.com/dperson/samba
# -u "<username;password>[;ID;group;GID]"  #Add a user
# -s  "<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]"

# docker pull dperson/samba

# display share info
# smbclient -NL //serverip
#       Sharename       Type      Comment
#       ---------       ----      -------
#       share1          Disk      publicSharea
#       share2          Disk      publicShareb
#       IPC$            IPC       IPC Service (Samba Server)

# cifs is dialect of samba
# net-fs/cifs-utils
# mount.cifs //serverip/share1 /mnt -o username=zero,password=0,vers=3.0
# mount.cifs //serverip/share1 /mnt -o username=zero,password=0,vers=3.1.1
# mount.smb3 //serverip/share1 /mnt -o username=zero,password=0

# user zero, passwd 0
# user admin, passwd 0
docker run --name samba \
    -d \
    --restart always \
    -p 139:139 -p 445:445 \
    -e USERID="0" \
    -e GROUPID="0" \
    -v /host/share/dir1/:/share/d1 \
    -v /host/share/dir2/:/share/d2 \
    dperson/samba:latest \
        -u "admin;0" \
        -u "zero;0" \
        -s "share1;/share/d1;yes;no;no;zero;admin;admin;publicSharea" \
		-s "share2;/share/d2;yes;yes;no;zero;admin;admin;publicShareb"
