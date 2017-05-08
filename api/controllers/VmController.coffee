_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
Promise = require 'bluebird'
notFound = new Error 'not found'
reject = (err, res) ->
  if err == notFound
    return res.notFound()
  res.serverError err

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
        Promise.reject notFound

  up: (req, res) ->
    req.params.cmd = 'up'
    module.exports
      .cmd req
      .then res.ok
      .catch (err) ->
        reject err, res

  down: (req, res) ->
    req.params.cmd = 'down'
    module.exports
      .cmd req
      .then res.ok
      .catch (err) ->
        reject err, res

  restart: (req, res) ->
    req.params.cmd = 'restart'
    module.exports
      .cmd req
      .then res.ok
      .catch (err) ->
        reject err, res

  suspend: (req, res) ->
    req.params.cmd = 'suspend'
    module.exports
      .cmd req
      .then res.ok
      .catch (err) ->
        reject err, res

  resume: (req, res) ->
    req.params.cmd = 'resume'
    module.exports
      .cmd req
      .then res.ok
      .catch (err) ->
        reject err, res

  backup: (req, res) ->
    req.params.cmd = 'backup'
    module.exports
      .cmd req
      .then (process) ->
        res.attachment "backup.tar.xz"
        process.stdout.pipe res
      .catch (err) ->
        reject err, res

  restore: (req, res) ->
    req.params.cmd = 'restore'
    module.exports
      .cmd req
      .then (process) ->
        new Promise (resolve, reject) ->
          req
            .file 'file'
            .on 'error', reject
            .on 'data', (file) ->
              file
                .on 'error', reject   
                .pipe process.stdin
          process
            .on 'close', (rc) ->
              if rc == 0
                return resolve()
              reject "Restore with error code #{rc}"
          process.stderr
            .on 'data', (err) ->
              reject err.toString()
      .then res.ok, res.serverError
