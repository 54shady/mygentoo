# https://github.com/dperson/samba
# -u "<username;password>[;ID;group;GID]"  #Add a user
# -s  "<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]"

# docker pull dperson/samba

# user zero, passwd 0
# user admin, passwd 0
docker run --name mysamba \
    --detach \
    --restart always \
    --publish 139:139 --publish 445:445 \
    --env USERID="0" \
    --env GROUPID="0" \
    --volume /path-to-share-d1/:/share/d1 \
    --volume /path-to-share-d2/:/share/d2 \
    dperson/samba:latest \
        -u "admin;0" \
        -u "zero;0" \
        -s "a;/share/d1;yes;no;no;zero;admin;admin;publicSharea" \
        -s "b;/share/d2;yes;yes;no;zero;admin;admin;publicShareb"
