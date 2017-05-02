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
      cwd = sails.config.vagrant.cfgDir @name
      cmd = "env VAGRANT_CWD=#{cwd} vagrant #{op}"
      if 'status'
        sh.execAsync cmd
      else 
        sh.execAsync cmd
          .then =>
            @status()
          .then (status) =>
            Promise.resolve _.extend @, status: status

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
            
    backup: ->
      @sh.execAsync sails.config.vagrant.cmd.backup cwd: sails.config.vagrant.cfgPath, name: @name

    restore: ->
      @sh.execAsync sails.config.vagrant.cmd.restore cwd: sails.config.vagrant.cfgPath, name: @name

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
    cfgDir = sails.config.vagrant.cfgDir values.name
    cfgFile = sails.config.vagrant.cfgDir values.name, 'Vagrantfile'
    dataDir = sails.config.vagrant.cfgDir values.name, 'data'
    params = _.extend sails.config.vagrant, values

    try
      # create vm home folder
      sh
        .mkdir '-p', dataDir

      # create Vagrantfile
      sh
        .echo sails.config.vagrant.template()(params)
        .to path.join cfgFile

      # update /etc/exports
      sh
        .echo "#{dataDir} #{_.template(process.env.NFSOPTS)(params)}\n"
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
          cfgDir = sails.config.vagrant.cfgDir vm.name
          dataDir = sails.config.vagrant.cfgDir vm.name, 'data'

          try
            # delete vm home folder
            sh
              .rm '-rf', cfgDir

            # delete nfs exports entry for vm
            sh
              .grep '-v', dataDir, '/etc/exports'
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
