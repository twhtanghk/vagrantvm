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
    
  beforeCreate: (values, cb) ->
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

  afterDestroy: (vmlist, cb) ->
    Promise
     .all vmlist.map (vm) ->
       sails.services.vm
         .destroy vm
     .then ->
       cb()
     .catch cb
