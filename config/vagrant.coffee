fs = require 'fs'
path = require 'path'
_ = require 'lodash'
root = process.cwd()
url = require 'url'

['BOX', 'MEMORY', 'SSH', 'HTTP', 'ROOTURL'].map (name) ->
  if not (name of process.env)
    throw new Error 'process.env.#{name} not yet defined'

module.exports =
  vagrant:
    template: ->
      _.template fs.readFileSync path.join(module.exports.vagrant.cfgPath, 'cfg.template')
    hostname: url.parse(process.env.ROOTURL).hostname
    cfgPath: path.join root, 'config/vagrant'
    box: process.env.BOX
    memory: parseInt process.env.MEMORY
    portStart:
      ssh: parseInt process.env.SSH
      http: parseInt process.env.HTTP
    upStatus: process.env.upStatus  
