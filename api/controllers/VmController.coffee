_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
PQueue = require 'p-queue'
queue = new PQueue concurrency: 1
Promise = require 'bluebird'
notFound = new Error 'not found'
reject = (err, res) ->
  if err == notFound
    return res.notFound()
  res.serverError err

module.exports =
  passwd: (req, res) ->
    Model = actionUtil.parseModel req
    pk = actionUtil.requirePk req
    {passwd} = actionUtil.parseValues req
    Model
      .findOne pk
      .then (vm) ->
        if not vm?
          return res.notFound()
        vm.passwd passwd
        res.ok vm
      .catch res.negotiate

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

  listAll: (req, res) ->
    @find req, res

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
                .on 'error', reject
          process
            .on 'close', (rc) ->
              if rc == 0
                return resolve()
              reject "Restore with error code #{rc}"
          process.stderr
            .on 'data', reject
      .then res.ok, (err) ->
        res.serverError err.toString()
