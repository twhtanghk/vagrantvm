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
        if last?
          ret = {ssh: last.ssh + 1, http: last.http + 1}
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
      .genFile values
      .then ->
        cb()
      .catch cb
