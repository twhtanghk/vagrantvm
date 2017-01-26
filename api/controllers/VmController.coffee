sh = require 'shelljs'

module.exports =
  cmd: (req, res) ->
    cmd = req.params.cmd
    name = req.params.name
    sh.cd sails.services.cfgDir name
    sh.exec "vagrant #{cmd}"

  up: (req, res) ->
    req.params.cmd = 'up'
    module.exports.cmd req, res

  down: (req, res) ->
    req.params.cmd = 'down'
    module.exports.cmd req, res

  restart: (req, res) ->
    req.params.cmd = 'reload'
    module.exports.cmd req, res

  suspend: (req, res) ->
    req.params.cmd = 'suspend'
    module.exports.cmd req, res

  resume: (req, res) ->
    req.params.cmd = 'resume'
    module.exports.cmd req, res
