[
  'DISK'
  'DISKMAX'
  'MEMORY'
  'MEMORYMAX'
].map (name) ->
  if not (name of process.env)
    throw new Error "process.env.#{name} not yet defined"

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

    # disk size in GB
    disk:
      type: 'integer'
      required: true
      defaultsTo: process.env.DISK
      min: process.env.DISK
      max: process.env.DISKMAX

    # memory size in MB
    memory:
      type: 'integer'
      required: true
      defaultsTo: process.env.MEMORY
      min: process.env.MEMORY
      max: process.env.MEMORYMAX

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
          if rc != 0
            return reject err
          resolve out
        ret.stderr.pipe process.stderr
        ret.stdout.pipe process.stdout
        if async
          resolve()

    status: ->
      @cmd 'status'
        .then (status) ->
          pattern = /^default[ ]*(.*)$/m
          pattern.exec(status)?[1]
    
    up: ->
      @cmd 'status'
        .then (status) =>
          pattern = /^default[ ]*(.*)$/m
          if pattern.exec(status)?[1] == sails.config.vagrant.upStatus
            sails.log.info "vm already running"
          else  
            sails.log.info "vm start up"
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
      .sort 'createdAt DESC'
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
    if values.disk > process.env.DISKMAX
      values.disk = process.env.DISKMAX
    if values.memory > process.env.MEMORYMAX
      values.memory = process.env.MEMORYMAX
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
