#!/bin/sh

root=~/prod/todosailsnew
sails=`which sails`

forever start --workingDir ${root} -a -l todosailsnew.log ${sails} lift --prod