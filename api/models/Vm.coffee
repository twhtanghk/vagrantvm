[
  'DISK'
  'DISKMAX'
  'MEMORY'
  'MEMORYMAX'
  'NFSOPTS'
].map (name) ->
  if not (name of process.env)
    throw new Error "process.env.#{name} not yet defined"

_ = require 'lodash'
path = require 'path'
Promise = require 'bluebird'
sh = require 'shelljs'
sh.execAsync = (cmd, async = false) ->
  new Promise (resolve, reject) ->
    ret = sh.exec cmd, {aysnc: async, silent: true}, (rc, out, err) ->
      if rc != 0
        return reject err
      resolve out
    ret.stderr.pipe process.stderr
    ret.stdout.pipe process.stdout
    if async
      resolve()
    
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
      cmd = "env VAGRANT_CWD=#{module.exports.cfgDir @} vagrant #{op}"
      if op == 'status'
        sh.execAsync cmd
      else 
        sh
          .execAsync cmd, async
          .then @status
          .then (status) =>
            Promise.resolve _.extend @, status: status

    status: ->
      @cmd 'status'
        .then (status) ->
          pattern = /^default[ ]*(.*)$/m
          pattern.exec(status)?[1]
    
    up: ->
      @status()
        .then (status) =>
          if status == 'running (libvirt)'
            Promise.resolve @
          else  
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
            
    backup: ->
      sh.execAsync sails.config.vagrant.cmd.backup cwd: module.exports.dataDir @

    restore: ->
      sh.execAsync sails.config.vagrant.cmd.restore cwd: module.exports.dataDir @

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
      
  beforeCreate: (values, cb) ->
    params = _.extend sails.config.vagrant, values

    try
      # create vm home folder
      sh
        .mkdir '-p', module.exports.dataDir values

      # create Vagrantfile
      sh
        .echo sails.config.vagrant.template()(params)
        .to module.exports.cfgFile values

      # update /etc/exports
      sh
        .echo "#{module.exports.dataDir values} #{_.template(process.env.NFSOPTS)(params)}\n"
        .toEnd '/etc/exports'
      sh
        .exec 'exportfs -avr'

      cb()
    catch e
      cb e

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
                # delete vm home folder
                sh
                  .rm '-rf', module.exports.cfgDir vm

                # delete nfs exports entry for vm
                sh
                  .grep '-v', module.exports.dataDir(vm), '/etc/exports'
                  .to "/tmp/#{vm.name}.tmp"
                sh
                  .mv "/tmp/#{vm.name}.tmp", '/etc/exports'
                sh
                  .exec 'exportfs -avr'
              catch e
                Promise.reject e
      .then ->
        cb()
      .catch cb

  cfgFile: (vm) ->
    path.join module.exports.cfgDir(vm), 'Vagrantfile'

  cfgDir: (vm) ->
    sails.config.vagrant.cfgDir 'data', vm.name
    
  dataDir: (vm) ->
    path.join module.exports.cfgDir(vm), 'data'
