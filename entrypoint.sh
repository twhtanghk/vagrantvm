#!/bin/sh

rpcbind
rpc.statd
rpc.nfsd
rpc.mountd
exportfs -avr
node_modules/.bin/gulp
node app.js --prod
