ip = require 'ip'
os = require 'os'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
url = require 'url'

module.exports =
  vagrant:
    disk: # GB
      min: 20
      max: 80
    memory: # GB
      min: 2
      max: 4
    net: '192.168.121.0/24'
    template: ->
      _.template fs.readFileSync path.join(module.exports.vagrant.cfgPath, 'cfg.template')
    ip:
      vm: os.networkInterfaces()['eth0'][0].address
    cfgPath: path.join __dirname, '../vm'
    cfgDir: (dir...) ->
      dir.unshift module.exports.vagrant.cfgPath
      path.join dir...
    box: 'debian/jessie64'
    port:
      http: 8000
      vnc: 5900
    passwd: 'default_vnc_passwd'
