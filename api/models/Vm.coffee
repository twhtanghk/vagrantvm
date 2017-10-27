_ = require 'lodash'
_.defaults = require 'merge-defaults'
path = require 'path'
Promise = require 'bluebird'
vagrant = require 'node-vagrant'
sh = require 'shelljs'

cfg =
  file: (vm) ->
    path.join cfg.dir(vm), 'Vagrantfile'

  dir: (vm) ->
    path.join sails.config.vagrant.cfgDir 'data', vm.name
    
  create: (vm) ->
    # create vm home folder
    sh
      .mkdir '-p', cfg.dir vm

    # create Vagrantfile
    params = _.defaults {}, vm, sails.config.vagrant
    sh
      .echo sails.config.vagrant.template()(params)
      .to cfg.file vm
    
  destroy: (vm) ->
    sh
      .rm '-rf', cfg.dir vm

module.exports =

  tableName: 'vm'

  schema: true

  attributes:

    name:
      type: 'string'
      required: true
      unique: true
      alphanumeric: true

    # disk size in GB
    disk:
      type: 'integer'
      required: true
      defaultsTo: sails.config.vagrant.disk.min
      min: sails.config.vagrant.disk.min
      max: sails.config.vagrant.disk.max

    # memory size in GB
    memory:
      type: 'integer'
      required: true
      defaultsTo: sails.config.vagrant.memory.min
      min: sails.config.vagrant.memory.min
      max: sails.config.vagrant.memory.max

    port:
      type: 'json'
      required: true

    createdBy:
      model: 'user'
      required:  true

    machine: ->
      Promise.promisifyAll vagrant.create cwd: cfg.dir @

    cmd: (op) ->
      @machine()["#{op}Async"]()
        .then (out) ->
          sails.log.info out
          out
        .catch (err) ->
          sails.log.error err
          Promise.reject err

    status: ->
      @cmd 'status'
        .then (res) ->
          res.default.status
    
    up: ->
      @status()
        .then (status) =>
          if status == 'running'
            return _.extend status: status, @
          else  
            @cmd 'up'
        
    down: ->
      @cmd 'halt'

    restart: ->
      @cmd 'reload'

    suspend: ->
      @cmd 'suspend'

    resume: ->
      @cmd 'resume'

    passwd: (passwd) ->
      try
        cfg.create _.defaults passwd: passwd, @
      catch err
        sails.log.error err

    destroy: ->
      @cmd 'destroy'
            
  nextPort: ->
    Vm
      .find()
      .sort 'createdAt DESC'
      .limit 1
      .then (last) ->
        ret = sails.config.vagrant.port
        if last.length == 1
          ret = 
            http: last[0].port.http + 1
            vnc: last[0].port.vnc + 1
        ret

  beforeValidate: (values, cb) ->
    Vm
      .nextPort()
      .then (port) ->
        values.port = port
        cb()
      .catch cb
      
  beforeCreate: (values, cb) ->
    try
      cfg.create values
      cb()
    catch e
      cb e

  afterCreate: (record, cb) ->
    sails.config.webhook.reload().catch sails.log.error
    cb()

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
              try
                cfg.destroy vm
              catch e
                Promise.reject e
      .then ->
        cb()
      .catch cb

  afterDestroy: (records, cb) ->
    @afterCreate null, cb
