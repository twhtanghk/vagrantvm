#!/bin/sh

rpcbind
rpc.statd
rpc.nfsd
rpc.mountd
node_modules/.bin/gulp
node app.js --prod
