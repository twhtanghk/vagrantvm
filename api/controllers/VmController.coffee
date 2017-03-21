_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
Promise = require 'bluebird'

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

  find: (req, res) ->
    Model = actionUtil.parseModel req
    cond = actionUtil.parseCriteria req

    Promise
      .all [
        Model.count()
          .where cond
          .toPromise()
        Model.find()
          .where cond
          .populateAll()
          .limit actionUtil.parseLimit req
          .skip actionUtil.parseSkip req
          .sort actionUtil.parseSort req
          .then (list) ->
            Promise.map list, (model) ->
              model.status()
                .then (status) ->
                  _.extend model, status: status
      ]
      .then (result) ->
        [count, results] = result
        res.ok
          count: count
          results: results
      .catch res.serverError

  cmd: (req, res) ->
    pk = actionUtil.requirePk req
    sails.models.vm
      .findOne id: pk
      .then (vm) ->
        if vm?
          return vm[req.params.cmd]()
            .then ->
              vm.status()
            .then (status) ->
              res.ok _.extend(vm, status: status)
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
