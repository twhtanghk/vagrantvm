_ = require 'lodash'
_.defaults = require 'merge-defaults'
path = require 'path'
Promise = require 'bluebird'
sh = require 'shelljs'
sh.execAsync = (cmd, opts = {}) ->
  _.defaults opts,
    async: false
    silent: true
  if opts.async
    return Promise.resolve sh.exec cmd, opts
  new Promise (resolve, reject) ->
    sh.exec cmd, opts, (rc, out, err) ->
      if rc != 0
        return reject err
      resolve out
    
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

    cmd: (op, opts = {}) ->
      cmd = "env VAGRANT_CWD=#{cfg.dir @} vagrant #{op}"
      if op == 'status'
        sh.execAsync cmd
      else 
        sh
          .execAsync cmd, opts
          .then =>
            @status()
          .then (status) =>
            Promise.resolve _.extend status: status, @

    status: ->
      @cmd 'status'
        .then (status) ->
          pattern = /^default[ ]*(.*)$/m
          pattern.exec(status)?[1]
    
    up: ->
      @status()
        .then (status) =>
          if status == 'running (libvirt)'
            Promise.resolve _.extend status: status, @
          else  
            @cmd 'up', async: true
        
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
