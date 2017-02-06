actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
sh = require 'shelljs'

module.exports =
  findOne: (req, res) ->
    pk = actionUtil.requirePk req
    sails.models.vm
      .findOne id: pk
      .then (vm) ->
        if vm?
          return vm.status()
            .then (status) ->
              res.json _.extend vm, status: status
        res.notFound()
      .catch res.serverError

  cmd: (req, res) ->
    pk = actionUtil.requirePk req
    sails.models.vm
      .findOne id: pk
      .then (vm) ->
        if vm?
          return vm[req.params.cmd]()
            .then ->
              res.ok()
        res.notFound()
      .catch res.serverError

  up: (req, res) ->
    req.params.cmd = 'up'
    module.exports.cmd req, res

  down: (req, res) ->
    req.params.cmd = 'down'
    module.exports.cmd req, res

  restart: (req, res) ->
    req.params.cmd = 'restart'
    module.exports.cmd req, res

  suspend: (req, res) ->
    req.params.cmd = 'suspend'
    module.exports.cmd req, res

  resume: (req, res) ->
    req.params.cmd = 'resume'
    module.exports.cmd req, res
