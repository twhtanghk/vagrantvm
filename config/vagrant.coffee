ip = require 'ip'
os = require 'os'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
url = require 'url'

[
  'BOX'
  'SSH'
  'HTTP'
  'NET'
].map (name) ->
  if not (name of process.env)
    throw new Error "process.env.#{name} not yet defined"

module.exports =
  vagrant:
    template: ->
      _.template fs.readFileSync path.join(module.exports.vagrant.cfgPath, 'cfg.template')
    net: process.env.NET
    ip:
      nfs: ip.or ip.cidr(process.env.NET), '0.0.0.1'
      vm: os.networkInterfaces()[process.env.INTERFACE || 'eth0'][0].address
    cfgPath: path.join __dirname, '../vm'
    cfgDir: (dir...) ->
      dir.unshift module.exports.vagrant.cfgPath
      path.join dir...
    box: process.env.BOX
    portStart:
      ssh: parseInt process.env.SSH
      http: parseInt process.env.HTTP
    cmd:
      backup: _.template "tar -C <%=cwd%> -cJf - ." 
      restore: _.template "tar -C <%=cwd%> -xJf - ."
