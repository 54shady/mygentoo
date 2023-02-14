ARG BUILD_FROM=alpine:latest

FROM $BUILD_FROM
# build with default argument
# docker build . -t tagname
#
# build with new argument
# docker build . -t tagname --build-arg BUILD_FROM=newimage

RUN set -eux && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk --update --no-cache add bash nfs-utils && \
                                                  \
    # remove the default config files
    rm -v /etc/idmapd.conf /etc/exports

# add a default exports file
RUN echo "/share *(rw,sync,no_root_squash)" >> /etc/exports

# http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
RUN mkdir -p /var/lib/nfs/rpc_pipefs                                                     && \
    mkdir -p /var/lib/nfs/v4recovery                                                     && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab


EXPOSE 2049

# setup entrypoint
COPY ./entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
