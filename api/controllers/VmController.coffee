_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
PQueue = require 'p-queue'
queue = new PQueue concurrency: 1
Promise = require 'bluebird'

module.exports =

  create: (req, res) ->
    Model = actionUtil.parseModel req
    data = actionUtil.parseValues req
    # ensure only 1 request entering the critical section to create vm
    queue
      .add ->
        Model
          .create data
          .toPromise()
      .then (record) ->
        res.created record
      .catch res.negotiate

  findOne: (req, res) ->
    pk = actionUtil.requirePk req
    sails.models.vm
      .findOne id: pk
      .then (vm) ->
        if vm?
          return vm.status()
            .then (status) ->
              res.ok _.extend vm, status: status
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

  listAll: (req, res) ->
    @find req, res

  cmd: (req, res) ->
    pk = actionUtil.requirePk req
    cmd = req.params.cmd
    values = actionUtil.parseValues req
    sails.models.vm
      .findOne pk
      .then (vm) ->
        if vm?
          switch cmd
            when 'up'
              vm[cmd]()
              res.ok vm
            when 'passwd'
              vm[cmd](values.passwd)
                .then ->
                  vm.status()
                .then (status) ->
                  res.ok _.extend(vm, status: status)
            else
              vm[cmd]()
                .then ->
                  vm.status()
                .then (status) ->
                  res.ok _.extend(vm, status: status)
        else
          res.notFound()
      .catch res.negotiate
