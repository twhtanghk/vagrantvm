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
    nfsopts: '*(rw,no_subtree_check,no_root_squash,fsid=<%=port.ssh%>)'
    template: ->
      _.template fs.readFileSync path.join(module.exports.vagrant.cfgPath, 'cfg.template')
    ip:
      nfs: ->
        ip.or ip.cidr(module.exports.vagrant.net), '0.0.0.1'
      vm: os.networkInterfaces()['eth0'][0].address
    cfgPath: path.join __dirname, '../vm'
    cfgDir: (dir...) ->
      dir.unshift module.exports.vagrant.cfgPath
      path.join dir...
    box: 'debian/jessie64'
    port:
      ssh: 2200
      http: 8000
      vnc: 5900
    cmd:
      backup: _.template "tar -C <%=cwd%> -cJf - ." 
      restore: _.template "tar -C <%=cwd%> -xJf - ."
