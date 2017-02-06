fs = require 'fs'
path = require 'path'
_ = require 'lodash'
root = process.cwd()

if not ('BOX' of process.env)
  throw new Error 'process.env.BOX not yet defined'
if not ('MEMORY' of process.env)
  throw new Error 'process.env.MEMORY not yet defined'
if not ('SSH' of process.env)
  throw new Error 'process.env.SSH not yet defined'
if not ('HTTP' of process.env)
  throw new Error 'process.env.HTTP not yet defined'

module.exports =
  vagrant:
    template: ->
      _.template fs.readFileSync path.join(module.exports.vagrant.cfgPath, 'cfg.template')
    cfgPath: path.join root, 'config/vagrant'
    box: process.env.BOX
    memory: parseInt process.env.MEMORY
    portStart:
      ssh: parseInt process.env.SSH
      http: parseInt process.env.HTTP
