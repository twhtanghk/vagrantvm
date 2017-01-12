#!/bin/sh

root=~/prod/proxyvm
sails=`which sails`

forever start --workingDir ${root} -a -l proxyvm.log ${sails} lift --prod