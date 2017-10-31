    path = require 'path'

    module.exports =

      vm:

url to access api for http reverse proxy 

        url: 'https://abc.com/vm'
        
model to acccess http reverse proxy api

        model: ->
          stamp = sails.config
            .armodel sails.config.vm.url
            .statics
              fetchFull: (opts) ->
                yield @fetchAll _.defaults url: "#{@baseUrl}/full", opts
            .methods
              getStamp: ->
                stamp
              cmdUrl: (cmd) ->
                "#{stamp.url('update', _.pick(@, stamp.idAttribute))}/#{cmd}"
              up: ->
                yield @save {}, url: @cmdUrl 'up'
              down: ->
                yield @save {}, url: @cmdUrl 'down'
              restart: ->
                yield @save {}, url: @cmdUrl 'restart'
              suspend: ->
                yield @save {}, url: @cmdUrl 'suspend'
              resume: ->
                yield @save {}, url: @cmdUrl 'resume'
              passwd: (passwd) ->
                yield @save {passwd: passwd}, url: @cmdUrl 'passwd'
            .use sails.config.api().use sails.config.oauth2.getOpts
