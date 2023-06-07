docker run --name nfs -d --restart always --net=host --privileged \
	-v ${HOME}/Share:/share \
	-v ${HOME}/d:/dict \
	-v /golden:/golden \
	-v /iso:/iso \
	-v /data/winapp:/app \
	-v /golden/fabvm/nfs_rootfs/target:/nfsrootfs \
	-v /lib/modules:/lib/modules:ro \
	--cap-add SYS_MODULE \
	-v ${PWD}/exports.txt:/etc/exports alpine/nfs
