fs = require 'fs'
path = require 'path'
_ = require 'lodash'
root = process.cwd()

module.exports =
  vagrant:
    template: ->
      _.template fs.readFileSync path.join(root, 'config/vagrant/cfg.template')
    cfgPath: path.join root, 'config/vagrant'
    box: 'debian/jessie64'
    memory: 1024
    portStart:
      ssh: process.env.SSH
      http: process.env.HTTP
