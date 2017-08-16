#!/bin/sh

rpcbind
rpc.statd
rpc.nfsd
rpc.mountd
exportfs -avr
libvirtd -d
node_modules/.bin/gulp
node app.js --prod
