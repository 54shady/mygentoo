# https://github.com/dperson/samba
# -u "<username;password>[;ID;group;GID]"  #Add a user
# -s  "<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]"

# docker pull dperson/samba

# user zero, passwd 0
# user admin, passwd 0
docker run --name samba \
    -d \
    --restart always \
    -p 139:139 -p 445:445 \
    -e USERID="0" \
    -e GROUPID="0" \
    -v /host-share-dir1/:/share/d1 \
    -v /host-share-dir2/:/share/d2 \
    dperson/samba:latest \
        -u "admin;0" \
        -u "zero;0" \
        -s "share1;/share/d1;yes;no;no;zero;admin;admin;publicSharea" \
		-s "share2;/share/d2;yes;yes;no;zero;admin;admin;publicShareb"
