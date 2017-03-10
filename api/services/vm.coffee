_ = require 'lodash'
Promise = require 'bluebird'
fs = Promise.promisifyAll require 'fs-extra'
path = require 'path'
child_process = require('child_process')

cfgDir = (vm) ->
  path.join sails.config.vagrant.cfgPath, vm.name

module.exports = 
  cfgDir: cfgDir

  create: (vm, cfg = sails.config.vagrant) ->
    cfgFile = path.join cfgDir(vm), 'Vagrantfile'
    params = _.extend sails.config.vagrant, vm
    fs
      .mkdirsAsync cfgDir vm
      .then ->
        out = fs.createWriteStream cfgFile
        out.write sails.config.vagrant.template()(params)
        out.end()

  destroy: (vm) ->
    fs
      .removeAsync cfgDir vm
