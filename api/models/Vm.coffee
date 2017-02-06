Promise = require 'bluebird'
sh = require 'shelljs'
    
module.exports =

  tableName: 'vm'

  schema: true

  attributes:

    name:
      type: 'string'
      required: true
      unique: true

    port:
      type: 'json'
      required: true

    createdBy:
      model: 'user'
      required:  true

    cmd: (op, async = false) ->
      cwd = sails.services.vm.cfgDir @
      new Promise (resolve, reject) ->
        ret = sh.exec "env VAGRANT_CWD=#{cwd} vagrant #{op}", {async: async, silent: true}, (rc, out, err) ->
          if err?
            return reject err
          resolve out
        if async
          ret.stderr.pipe process.stderr
          ret.stdout.pipe process.stdout
          resolve()

    status: ->
      @cmd 'status'
        .then (status) ->
          pattern = /^default[ ]*(.*)$/m
          pattern.exec(status)?[1]
        .catch sails.log.error

    up: ->
      @cmd 'up', true

    down: ->
      @cmd 'halt'

    restart: ->
      @cmd 'reload'

    suspend: ->
      @cmd 'suspend'

    resume: ->
      @cmd 'resume'

    destroy: ->
      @cmd 'destroy'
            
  nextPort: (cb) ->
    Vm
      .find()
      .sort 'createAt DESC'
      .limit 1
      .then (last) ->
        ret = sails.config.vagrant.portStart
        if last.length == 1
          ret = 
            ssh: last[0].port.ssh + 1
            http: last[0].port.http + 1
        cb null, ret
      .catch cb
    
  beforeValidate: (values, cb) ->
    Vm
      .nextPort (err, port) ->
        if err?
          return cb err
        values.port = port
        cb()
      
  afterCreate: (values, cb) ->
    sails.services.vm
      .create values
      .then ->
        cb()
      .catch cb

  beforeDestroy: (criteria, cb) ->
    sails.models.vm
      .find criteria
      .then (vmlist) ->
        Promise.map vmlist, (vm) ->
          vm
            .down()
            .then ->
              vm.destroy()
            .then ->
              sails.services.vm
                .destroy vm
      .then ->
        cb()
      .catch cb
