_ = require 'lodash'
path = require 'path'
sh = require 'shelljs'

['NFSSERVER', 'NFSOPTS'].map (name) ->
  if not (name of process.env)
    throw new Error "process.env.#{name} not yet defined"

cfgDir = (vm) ->
  path.join sails.config.vagrant.cfgPath, vm.name

module.exports = 
  cfgDir: cfgDir

  create: (vm, cfg = sails.config.vagrant) ->
    cfgFile = path.join cfgDir(vm), 'Vagrantfile'
    params = _.extend sails.config.vagrant, vm, hostip: process.env.NFSSERVER

    # create home folder
    sh.mkdir '-p', path.join(cfgDir(vm), 'home')

    # create Vagrantfile
    sh
      .echo sails.config.vagrant.template()(params)
      .to cfgFile

    # update /etc/exports
    sh
      .echo "#{home} #{_.template(process.env.NFSOPTS)(params)}"
      .toEnd '/etc/exports'
    sh
      .exec 'exportfs -avr'

  destroy: (vm) ->
    # delete home folder
    sh
      .rm '-rf', cfgDir vm

    # remove nfs exports entry for vm
    sh
      .grep '-v', cfgDir(vm), '/etc/exports'
      .to "/tmp/#{vm.name}.tmp"
    sh
      .mv "/tmp/#{vm.home}.tmp", '/etc/exports'
    sh
      .exec 'exportfs -avr'
