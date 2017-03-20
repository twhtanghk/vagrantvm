_ = require 'lodash'
path = require 'path'
sh = require 'shelljs'
Promise = require 'bluebird'

if not ('NFSOPTS' of process.env)
  throw new Error "process.env.NFSOPTS not yet defined"

cfgDir = (vm) ->
  path.join sails.config.vagrant.cfgPath, vm.name

module.exports = 
  cfgDir: cfgDir

  create: (vm, cfg = sails.config.vagrant) ->
    cfgFile = path.join cfgDir(vm), 'Vagrantfile'
    params = _.extend sails.config.vagrant, vm

    new Promise (resolve, reject) ->
      try
        # create home folder
        sh.mkdir '-p', cfgDir(vm)

        # create Vagrantfile
        sh
          .echo sails.config.vagrant.template()(params)
          .to cfgFile

        # update /etc/exports
        sh
          .echo "#{cfgDir(vm)} #{_.template(process.env.NFSOPTS)(params)}"
          .toEnd '/etc/exports'
        sh
          .exec 'exportfs -avr'

        resolve()
      catch e
        reject e

  destroy: (vm) ->
    new Promise (resolve, reject) ->
      try
        # delete home folder
        sh
          .rm '-rf', cfgDir vm

        # remove nfs exports entry for vm
        sh
          .grep '-v', cfgDir(vm), '/etc/exports'
          .to "/tmp/#{vm.name}.tmp"
        sh
          .mv "/tmp/#{vm.name}.tmp", '/etc/exports'
        sh
          .exec 'exportfs -avr'
        resolve()
      catch e
        reject e
