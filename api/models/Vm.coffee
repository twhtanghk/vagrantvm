_ = require 'lodash'
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

    # memory size in MB
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
      cmd = "env VAGRANT_CWD=#{module.exports.cfgDir @} vagrant #{op}"
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

    destroy: ->
      @cmd 'destroy'
            
    backup: ->
      sh.execAsync sails.config.vagrant.cmd.backup(cwd: module.exports.dataDir @), { async: true, encoding: 'buffer' }

    restore: ->
      sh.execAsync sails.config.vagrant.cmd.restore(cwd: module.exports.dataDir @), { async: true, encoding: 'buffer' }

  nextPort: (cb) ->
    Vm
      .find()
      .sort 'createdAt DESC'
      .limit 1
      .then (last) ->
        ret = sails.config.vagrant.port
        if last.length == 1
          ret = 
            ssh: last[0].port.ssh + 1
            http: last[0].port.http + 1
            vnc: last[0].port.vnc + 1
        cb null, ret
      .catch cb
    
  beforeValidate: (values, cb) ->
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
        .echo "#{module.exports.dataDir values} #{_.template(sails.config.vagrant.nfsopts)(params)}\n"
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
