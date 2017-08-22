#!/bin/sh

rpcbind
rpc.statd
rpc.nfsd
rpc.mountd
exportfs -avr
libvirtd -d
virsh pool-define-as default dir --target /var/lib/libvirt/images/
virsh pool-autostart default
virsh pool-start default
node_modules/.bin/gulp
node app.js --prod
