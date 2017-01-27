sh = require 'shelljs'

module.exports =
  cmd: (req, res) ->
    cmd = req.params.cmd
    id = req.params.id
    sails.models.vm
      .findOne
        id: id
        createdBy: req.user.email
      .then (vm) ->
        if vm?
          sh.cd sails.services.vm.cfgDir vm
          sh.exec "vagrant #{cmd}", (code, out, err) ->
            res.ok code
        else
          res.notFound()

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
