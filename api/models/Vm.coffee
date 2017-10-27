_ = require 'lodash'
_.defaults = require 'merge-defaults'
path = require 'path'
Promise = require 'bluebird'
vagrant = require 'node-vagrant'
sh = require 'shelljs'

###
class hierarchy: libvirt -> vagrant cfg -> model
cfg hide libvirt details
###
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
    @cmd vm, 'destroy'
      .then ->
        sh
          .rm '-rf', cfg.dir vm

  machine: (vm) ->
    Promise.promisifyAll vagrant.create cwd: cfg.dir vm

  cmd: (vm, op) ->
    @machine(vm)["#{op}Async"]()
      .then (out) ->
        sails.log.info out
        out
      .catch (err) ->
        sails.log.error err
        Promise.reject err

  status: (vm) ->
    @cmd vm, 'status'
      .then (res) ->
        res.default.status
    
  up: (vm) ->
    @status vm
      .then (status) =>
        if status == 'running'
          return _.extend status: status, vm
        else  
          @cmd vm, 'up'
        
  down: (vm) ->
    @cmd vm, 'halt'

  restart: (vm) ->
    @cmd vm, 'reload'

  suspend: (vm) ->
    @cmd vm, 'suspend'

  resume: (vm) ->
    @cmd vm, 'resume'

  passwd: (vm, passwd) ->
    try
      Promise.resolve cfg.create _.defaults passwd: passwd, vm
    catch err
      sails.log.error err
      Promise.reject err

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

    status: ->
      cfg.status @

    up: ->
      cfg.up @

    down: ->
      cfg.down @

    restart: ->
      cfg.restart @

    suspend: ->
      cfg.supsend @

    resume: ->
      cfg.resume @

    passwd: (passwd) ->
      cfg.passwd @, passwd

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
      
  afterCreate: (record, cb) ->
    try
      cfg.create record
      sails.config.webhook.reload().catch sails.log.error
      cb()
    catch e
      cb e

  beforeDestroy: (criteria, cb) ->
    Vm
      .find criteria
      .then (records) ->
        Promise
          .map records, (vm) ->
            try
              cfg.destroy vm
            catch e
              Promise.reject e
      .then ->
        cb()
      .catch cb

  afterDestroy: (records, cb) ->
    sails.config.webhook.reload().catch sails.log.error
    cb()
