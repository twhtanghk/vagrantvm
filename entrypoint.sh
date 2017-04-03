#!/bin/sh

echo '/usr/src/app/vm *(rw,no_subtree_check,no_root_squash,fsid=0)' >>/etc/exports
rpcbind
rpc.statd
rpc.nfsd
rpc.mountd
node_modules/.bin/gulp
node app.js --prod
